defmodule Cellect.Selection do
  def select("uniform", workflow_id, user_id) do
    select("uniform", workflow_id, user_id, 5)
  end

  def select("uniform", workflow_id, user_id, amount) do
    Cellect.Workflow.subject_set_ids(workflow_id)
    |> Enum.map(&(Cellect.Workflow.subject_ids(workflow_id, &1)))
    |> Enum.map(&uniform_chances/1)
    |> do_select(workflow_id, user_id, amount)
  end

  def do_select(streams, workflow_id, user_id, amount) do
    streams
    |> Cellect.StreamTools.interleave
    |> deduplicate
    |> reject_recently_retired
    |> reject_recently_selected
    |> reject_seen_subjects(workflow_id, user_id)
    |> Enum.take(amount)
  end

  def uniform_chances(ids) do
    stream = Stream.repeatedly(fn -> Enum.random(ids) end)
    %{stream: stream, chance: Enum.count(ids)}
  end

  def deduplicate(stream) do
    Stream.uniq(stream)
  end

  def reject_recently_retired(stream) do
    stream
  end

  def reject_recently_selected(stream) do
    stream
  end

  def reject_seen_subjects(stream, workflow_id, user_id) do
    seen_subject_ids = Cellect.User.seen_subject_ids(workflow_id, user_id) |> Enum.into(MapSet.new)
    Stream.reject(stream, fn x -> MapSet.member?(seen_subject_ids, x) end)
  end
end
