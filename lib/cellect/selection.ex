defmodule Cellect.Selection do
  def select_randomly(workflow, user_seen) do
    {subject_ids, retired_ids} = Cellect.WorkflowWorker.get(workflow)
    seen_ids = Cellect.UserSeenWorker.get(user_seen)

    Cellect.RandomSelection.sample(subject_ids, HashSet.union(seen_ids, retired_ids), 10)
  end
end
