defmodule Designator.UserProjectPreference do
  use Ecto.Schema
  import Ecto.Query, only: [from: 2]
  alias Designator.Repo

  schema "user_project_preferences" do
    field :project_id, :integer
    field :user_id, :integer
    field :settings, :map
  end

  def find(project_id, user_id) do
    query = from upp in __MODULE__,
      where: upp.project_id == ^project_id and upp.user_id == ^user_id

    Repo.one(query)
  end
end

