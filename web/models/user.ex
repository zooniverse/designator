defmodule Cellect.User do
  import Ecto.Query, only: [from: 2]

  def seen_subject_ids(workflow_id, nil), do: []
  def seen_subject_ids(workflow_id, user_id) do
    query = from uss in "user_seen_subjects",
      where: uss.workflow_id == ^workflow_id and uss.user_id == ^user_id,
      select: uss.subject_ids

    Cellect.Repo.one(query) || []
  end
end
