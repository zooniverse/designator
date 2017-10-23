defmodule Designator.User do
  import Ecto.Query, only: [from: 2]

  alias Designator.{Workflow, UserProjectPreference}

  def configuration(_workflow_id, nil), do: %{}
  def configuration(workflow_id, user_id) do
    with %{project_id: project_id} <- Workflow.find(workflow_id),
         %{preferences: preferences} <- UserProjectPreference.find(project_id, user_id),
         {:ok, designator_config} <- Map.fetch(preferences, "designator"),
         {:ok, workflow_config} <- Map.fetch(designator_config, Integer.to_string(workflow_id)) do
      workflow_config
    else
      _ -> %{}
    end
  end

  def seen_subject_ids(_workflow_id, nil), do: []
  def seen_subject_ids(workflow_id, user_id) do
    try do
      query = from uss in "user_seen_subjects",
        where: uss.workflow_id == ^workflow_id and uss.user_id == ^user_id,
        select: uss.subject_ids

      Designator.Repo.one(query) || []
    rescue
      DBConnection.ConnectionError -> []
    end
  end
end
