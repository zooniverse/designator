defmodule Cellect.Selection do
  def select("uniform", workflow_id, user_id) do
    Cellect.Workflow.subjects(workflow_id)
    |> Enum.take(5)
  end

  def select_randomly(workflow, user_seen) do
    {subject_ids, retired_ids} = Cellect.Workflow.Worker.get(workflow)
    seen_ids = Cellect.UserSeen.Worker.get(user_seen)

    Cellect.RandomSelection.sample(subject_ids, HashSet.union(seen_ids, retired_ids), 10)
  end
end
