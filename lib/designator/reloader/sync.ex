defmodule Designator.Reloader.Sync do
  use GenServer

  @behaviour Designator.Reloader

  def start_link() do
    GenServer.start_link(__MODULE__, {}, name: __MODULE__)
  end

  def reload_subject_sets(workflow_id) do
    headers = []
    options = [recv_timeout: 60_000]
    {:ok, response} = HTTPoison.get("https://panoptes.zooniverse.org/subject_selection_strategies/designator/subjects?workflow_id=#{workflow_id}", headers, options)
    %{"subjects" => subjects} = response.body |> Poison.decode!

    Enum.group_by(subjects, fn subject -> subject["subject_set_id"] end, fn subject -> subject["id"] end)
    |> Enum.each(fn {subject_set_id, subject_ids} ->
      Designator.SubjectSetCache.set_subject_ids({workflow_id, subject_set_id}, subject_ids)
    end)

    :ok
  end

  def reload_subject_set({workflow_id, subject_set_id}) do
    subject_ids = Designator.Workflow.subject_ids(workflow_id, subject_set_id) |> Array.from_list
    Designator.SubjectSetCache.set_subject_ids({workflow_id, subject_set_id}, subject_ids)
    :ok
  end
end
