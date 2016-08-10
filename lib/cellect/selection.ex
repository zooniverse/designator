defmodule Cellect.Selection do
  def select("uniform", workflow_id, user_id) do
    Cellect.Workflow.subject_ids(workflow_id)
    |> randomly_pick
    |> deduplicate
    |> unretired
    |> unseen
    |> Enum.take(5)
  end

  def randomly_pick(enumerable) do
    Stream.repeatedly(fn -> Enum.random(enumerable) end)
  end

  def deduplicate(stream) do
    Stream.uniq(stream)
  end

  def unretired(stream) do
    stream
  end

  def unseen(stream) do
    stream
  end

  # def select_randomly(workflow, user_seen) do
  #   {subject_ids, retired_ids} = Cellect.Workflow.Worker.get(workflow)
  #   seen_ids = Cellect.UserSeen.Worker.get(user_seen)

  #   Cellect.RandomSelection.sample(subject_ids, HashSet.union(seen_ids, retired_ids), 10)
  # end
end
