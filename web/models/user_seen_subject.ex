defmodule Cellect.UserSeenSubject do
  use Ecto.Schema
  import Ecto.Query, only: [from: 2]

  use Cellect.Web, :model

  schema "user_seen_subjects" do
    field :workflow_id, :integer
    field :user_id, :integer
    field :subject_ids, {:array, :integer}
    timestamps inserted_at: :created_at
  end

  def seen_subject_ids(workflow_id, nil), do: []
  def seen_subject_ids(workflow_id, user_id) do
    query = from uss in "user_seen_subjects",
      where: uss.workflow_id == ^workflow_id and uss.user_id == ^user_id,
      select: uss.subject_ids

    Cellect.Repo.one(query) || []
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:user_id, :workflow_id, :subject_ids])
  end

end
