defmodule Designator.Workflow do
  use Ecto.Schema
  import Ecto.Query, only: [from: 2]

  use Designator.Web, :model

  schema "workflows" do
    field :project_id, :integer
    field :configuration, :map
    field :prioritized, :boolean
    field :grouped, :boolean

    timestamps inserted_at: :created_at
  end

  def find(workflow_id) do
    __MODULE__ |> Designator.Repo.get(workflow_id)
  end

  def subject_set_ids(workflow_id) do
    query = from ssw in "subject_sets_workflows",
      where: ssw.workflow_id == ^workflow_id,
      select: ssw.subject_set_id

    Designator.Repo.all(query)
  end

  def subject_ids(workflow_id, subject_set_id) do
    query = from sms in "set_member_subjects",
      left_join: swc in "subject_workflow_counts", on: (sms.subject_id == swc.subject_id and swc.workflow_id == ^workflow_id),
      where: sms.subject_set_id == ^subject_set_id and is_nil(swc.retired_at),
      select: { sms.subject_id, fragment("CASE WHEN priority IS NULL THEN 0 ELSE priority END") }
    Designator.Repo.all(query)
    |> sort_decimal_values
    |> Enum.map(fn {k, _v} -> k end)
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:id, :configuration, :grouped, :prioritized])
  end

  def sort_decimal_values(result_tuples) do
    # sort_by/3 takes the following params
    # result set param for sorting
    # a mapper function to unpack the tuple index [1] decimal values
    # and a comparison function to sort on ensuring ascending order (elem 1 < elem 2)
    # https://hexdocs.pm/decimal/1.9.0/readme.html#comparisons
    Enum.sort_by(result_tuples, &elem(&1, 1), &Decimal.cmp(&1, &2) != :gt)
  end


end
