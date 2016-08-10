defmodule Cellect.Workflow do
  import Ecto.Query, only: [from: 2]

  def subject_set_ids(workflow_id) do
    query = from ssw in "subject_sets_workflows",
      where: ssw.workflow_id == ^workflow_id,
      select: ssw.subject_set_id

    Cellect.Repo.all(query)
  end

  def subject_ids(workflow_id, subject_set_id) do
    query = from s in "subjects",
      join: sms in "set_member_subjects", on: s.id == sms.subject_id,
      join: sw in "subject_sets_workflows", on: sw.subject_set_id == sms.subject_set_id,
      left_join: swc in "subject_workflow_counts", on: s.id == swc.subject_id,
      where: sw.workflow_id == ^workflow_id and sms.subject_set_id == ^subject_set_id and is_nil(swc.retired_at),
      select: s.id
    Cellect.Repo.all(query)
  end
end
