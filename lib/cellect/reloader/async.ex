defmodule Cellect.Reloader.Async do
  use ExActor.GenServer, export: :async_reloader

  @behaviour Cellect.Reloader

  defstart start_link() do
    initial_state %{}
  end

  defcast reload_subject_set({workflow_id, subject_set_id}), state: state do
    subject_ids = Cellect.Workflow.subject_ids(workflow_id, subject_set_id) |> Array.from_list
    Cellect.SubjectSetCache.set_subject_ids({workflow_id, subject_set_id}, subject_ids)
    noreply()
  end
end
