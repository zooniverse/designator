defmodule Designator.Selection do
  alias Designator.StreamTools
  alias Designator.SubjectStream

  def select(style, workflow_id, user_id), do: select(style, workflow_id, user_id, 5)

  def select("uniform", workflow_id, user_id, amount) do
    workflow = Designator.WorkflowCache.get(workflow_id)
    user = Designator.UserCache.get({workflow_id, user_id})
    seen_subject_ids = user.seen_ids

    streams = workflow.subject_set_ids
    |> Enum.map(fn subject_set_id -> Designator.SubjectSetCache.get({workflow.id, subject_set_id}) end)
    |> Enum.map(fn subject_set -> {subject_set.subject_set_id, subject_set.subject_ids} end)
    |> reject_empty_sets
    |> Enum.map(fn subject_set -> Designator.SubjectStream.build(subject_set) end)

    size = Enum.sum(Enum.map(streams, fn stream -> stream.amount end))

    do_select(streams, size, seen_subject_ids, amount, user)
  end

  def select("weighted", workflow_id, user_id, limit) do
    workflow = Designator.WorkflowCache.get(workflow_id)
    user = Designator.UserCache.get({workflow_id, user_id})
    seen_subject_ids = user.seen_ids
    gold_standard_set_ids = workflow.configuration["gold_standard_sets"] || []

    streams = get_streams(workflow)
    amount = Enum.sum(Enum.map(streams, fn stream -> stream.amount end))

    if Enum.count(gold_standard_set_ids) > 0 do
      gold_stream = streams |> Enum.filter(&Enum.member?(gold_standard_set_ids, &1.subject_set_id)) |> StreamTools.interleave
      test_stream = streams |> Enum.reject(&Enum.member?(gold_standard_set_ids, &1.subject_set_id)) |> StreamTools.interleave

      gold = %SubjectStream{stream: gold_stream, chance: gold_chance(Enum.count(seen_subject_ids))}
      test = %SubjectStream{stream: test_stream, chance: 1 - gold_chance(Enum.count(seen_subject_ids))}
      do_select([gold, test], amount, seen_subject_ids, limit, user)
    else
      do_select(streams, amount, seen_subject_ids, limit, user)
    end
  end

  def do_select(streams, stream_amount, seen_subject_ids, amount, user) do
    seen_size = Enum.count(seen_subject_ids)
    max_streamable = stream_amount - seen_size
    amount = min(max_streamable, amount)

    random_state = Process.get(:rand_seed)

    task = Task.async(fn ->
      if random_state, do: Process.put(:rand_seed, random_state)

      streams
      |> Designator.StreamTools.interleave
      |> deduplicate
      |> reject_recently_retired
      |> reject_recently_selected(user)
      |> reject_seen_subjects(seen_subject_ids)
      |> Enum.take(amount) # TODO: Breaks if not enough match
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

  def get_streams(workflow) do
    configured_set_weights = workflow.configuration["subject_set_weights"] || %{}

    workflow.subject_set_ids
    |> Enum.map(fn subject_set_id -> Designator.SubjectSetCache.get({workflow.id, subject_set_id}) end)
    |> Enum.map(fn subject_set -> {subject_set.subject_set_id, subject_set.subject_ids} end)
    |> reject_empty_sets
    |> Enum.map(fn subject_set -> Designator.SubjectStream.build(subject_set, configured_set_weights) end)
  end

  def gold_chance(n) when n in  0..20, do: 0.4
  def gold_chance(n) when n in 21..40, do: 0.3
  def gold_chance(n) when n in 41..60, do: 0.2
  def gold_chance(_),                  do: 0.1

  def deduplicate(stream) do
    Stream.uniq(stream)
  end

  def reject_empty_sets(sets) do
    Enum.filter(sets, fn({_, subject_ids}) -> Designator.SubjectStream.get_amount(subject_ids) > 0 end)
  end

  def reject_recently_retired(stream) do
    stream #TODO
  end

  def reject_recently_selected(stream, user) do
    Stream.reject(stream, fn x -> MapSet.member?(user.recently_selected_ids, x) end)
  end

  def reject_seen_subjects(stream, seen_subject_ids) do
    Stream.reject(stream, fn x -> MapSet.member?(seen_subject_ids, x) end)
  end
end
