defmodule Cellect.Cache.SubjectIds do
  use ExActor.GenServer, export: :subject_ids_cache

  defstart start_link() do
    initial_state %{}
  end

  defcall get(workflow_id), state: state do
    case state[workflow_id] do
      nil ->
        reload_async(workflow_id)
        reply([])
      ids ->
        if Enum.empty?(ids), do: reload_async(workflow_id)
        reply(ids)
    end
  end

  defcast set(workflow_id, ids), state: state do
    new_state Map.put(state, workflow_id, ids)
  end

  defcast reload_async(workflow_id), state: state do
    converter = fn subject_set_id ->
      {
        subject_set_id,
        Enum.into(Cellect.Workflow.subject_ids(workflow_id, subject_set_id), Array.new)
      }
    end

    ids = Cellect.Workflow.subject_set_ids(workflow_id)
    |> Enum.map(converter)
    |> Map.new

    set(workflow_id, ids)

    noreply
  end
end
