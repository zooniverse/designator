defmodule Cellect.Reloader.Sync do
  use ExActor.GenServer, export: :sync_reloader

  @behaviour Cellect.Reloader

  defstart start_link() do
    initial_state %{}
  end

  def reload_subject_set({workflow_id, subject_set_id}) do
    subject_ids = Cellect.Workflow.subject_ids(workflow_id, subject_set_id) |> Array.from_list
    Cellect.SubjectSetCache.set_subject_ids({workflow_id, subject_set_id}, subject_ids)
    :ok
  end
end
