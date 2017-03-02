defmodule Cellect.Reloader.Sync do
  use GenServer

  @behaviour Cellect.Reloader

  def start_link() do
    GenServer.start_link(__MODULE__, {}, name: __MODULE__)
  end

  def reload_subject_set({workflow_id, subject_set_id}) do
    subject_ids = Cellect.Workflow.subject_ids(workflow_id, subject_set_id) |> Array.from_list
    Cellect.SubjectSetCache.set_subject_ids({workflow_id, subject_set_id}, subject_ids)
    :ok
  end
end
