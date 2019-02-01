defmodule Designator.Selection do
  def select(_style, workflow_id, user_id, subject_set_id, limit \\ 5) do
    workflow = Designator.WorkflowCache.get(workflow_id)
    user = Designator.UserCache.get({workflow_id, user_id})
    seen_subject_ids = user.seen_ids

    streams = get_streams(workflow, user, subject_set_id)
    amount = Enum.sum(Enum.map(streams, fn stream -> stream.amount end))

    do_select(streams, amount, seen_subject_ids, limit, workflow, user)
  end

  defp do_select(streams, stream_amount, seen_subject_ids, amount, workflow, user) do
    seen_size = Enum.count(seen_subject_ids)
    max_streamable = stream_amount
    amount = min(max_streamable, amount)

    random_state = Process.get(:rand_seed)

    task = Task.async(fn ->
      if random_state, do: Process.put(:rand_seed, random_state)

      streams
      |> Designator.StreamTools.interleave
      |> deduplicate
      |> reject_recently_retired(workflow)
      |> reject_recently_selected(user)
      |> reject_seen_subjects(seen_subject_ids)
      |> Enum.take(amount)
    end)

    case Task.yield(task, 1000) || Task.shutdown(task) do
      {:ok, selected_ids} ->
        Designator.UserCache.add_recently_selected(user, selected_ids)
        selected_ids
      :nil ->
        Rollbax.report(:throw, :selection_timeout, System.stacktrace(),
          %{subject_set_ids: Enum.map(streams, &(&1.subject_set_id)),
            stream_amount: stream_amount,
            seen_size: seen_size})

        []
    end
  end

  def get_streams(workflow, user, subject_set_id) do
    selection_subject_set_ids(workflow.subject_set_ids, subject_set_id)
    |> get_subject_set_from_cache(workflow)
    |> reject_empty_sets
    |> convert_to_streams(workflow)
    |> Designator.Streams.ConfiguredWeights.apply_weights(workflow, user)
    |> Designator.Streams.ConfiguredChances.apply_weights(workflow, user)
    |> Designator.Streams.GoldStandard.apply_weights(workflow, user)
    |> Designator.Streams.Spacewarps.apply_weights(workflow, user)
    |> Designator.Streams.PlanetHunters.apply_weights(workflow, user)
  end

  defp get_subject_set_from_cache(subject_set_ids, workflow) do
    Enum.map(subject_set_ids, fn subject_set_id ->
      Designator.SubjectSetCache.get({workflow.id, subject_set_id})
    end)
  end

  def convert_to_streams(subject_sets, workflow) do
    Enum.map(subject_sets, fn subject_set ->
      Designator.SubjectStream.build(subject_set)
    end)
  end

  defp deduplicate(stream) do
    Stream.uniq(stream)
  end

  defp reject_empty_sets(sets) do
    Enum.filter(sets, fn subject_set -> Designator.SubjectStream.get_amount(subject_set.subject_ids) > 0 end)
  end

  defp reject_recently_retired(stream, workflow) do
    %{subject_ids: subject_ids} = Designator.RecentlyRetired.get(workflow.id)
    Stream.reject(stream, fn id -> MapSet.member?(subject_ids, id) end)
  end

  defp reject_recently_selected(stream, user) do
    Stream.reject(stream, fn x -> MapSet.member?(user.recently_selected_ids, x) end)
  end

  defp reject_seen_subjects(stream, seen_subject_ids) do
    Stream.reject(stream, fn x -> MapSet.member?(seen_subject_ids, x) end)
  end

  defp selection_subject_set_ids(all_subject_set_ids, subject_set_id) do
    if Enum.member?(all_subject_set_ids, subject_set_id) do
      [ subject_set_id ]
    else
      all_subject_set_ids
    end
  end
end
