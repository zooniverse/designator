defmodule Cellect.Cache.SubjectIds do
  use ExActor.GenServer, export: :subject_ids_cache

  defstart start_link(workflow_id) do
    initial_state %{workflow_id: workflow_id, subject_ids: %{}}
  end

  defcall get, state: %{subject_ids: ids} do
    if Enum.empty?(ids), do: reload_async()
    reply(ids)
  end

  defcast set(ids), state: state do
    new_state Map.put(state, :subject_ids, ids)
  end

  defcast reload_async(), state: %{workflow_id: workflow_id} do
    converter = fn subject_set_id ->
      {
        subject_set_id,
        Enum.into(Cellect.Workflow.subject_ids(workflow_id, subject_set_id), Array.new)
      }
    end

    Cellect.Workflow.subject_set_ids(workflow_id)
    |> Enum.map(converter)
    |> Map.new
    |> set

    noreply
  end
end
