defmodule Cellect.Workflow do
  use Ecto.Schema
  import Ecto.Query, only: [from: 2]

  use Cellect.Web, :model

  schema "workflows" do
    field :configuration, :map

    timestamps inserted_at: :created_at
  end

  def find(workflow_id) do
    __MODULE__ |> Cellect.Repo.get(workflow_id)
  end

  def subject_set_ids(workflow_id) do
    query = from ssw in "subject_sets_workflows",
      where: ssw.workflow_id == ^workflow_id,
      select: ssw.subject_set_id

    Cellect.Repo.all(query)
  end

  def subject_ids(workflow_id, subject_set_id) do
    query = from sms in "set_member_subjects",
      join: sw in "subject_sets_workflows", on: sw.subject_set_id == sms.subject_set_id,
      left_join: swc in "subject_workflow_counts", on: sms.subject_id == swc.subject_id,
      where: sw.workflow_id == ^workflow_id and (swc.workflow_id == ^workflow_id or is_nil(swc.workflow_id)) and sms.subject_set_id == ^subject_set_id and is_nil(swc.retired_at),
      select: sms.subject_id
    Cellect.Repo.all(query)
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:id, :configuration])
  end

end
