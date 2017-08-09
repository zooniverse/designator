defmodule Designator.Subject do
  import Ecto.Query, only: [from: 2]

  def unretired_ids(workflow_id) do
    query = from s in "subjects",
      join: sms in "set_member_subjects", on: s.id == sms.subject_id,
      join: sw in "subject_sets_workflows", on: sw.subject_set_id == sms.subject_set_id,
      left_join: swc in "subject_workflow_counts", on: s.id == swc.subject_id,
      where: sw.workflow_id == ^workflow_id and not(is_nil(swc.retired_at)),
      select: s.id
    Designator.Repo.all(query)
  end

  def seen_ids(workflow_id, user_id) do
    query = from uss in "user_seen_subjects",
      where: uss.workflow_id == ^workflow_id and uss.user_id == ^user_id,
      select: uss.subject_ids
    Designator.Repo.all(query)
  end
end
