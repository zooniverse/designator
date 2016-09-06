defmodule Cellect.Cache.Reloader do
  use ExActor.GenServer, export: :reloader

  defstart start_link() do
    initial_state %{}
  end

  defcast reload_workflow(cache, workflow_id), state: state do
    converter = fn subject_set_id ->
      {
        subject_set_id,
        Enum.into(Cellect.Workflow.subject_ids(workflow_id, subject_set_id), Array.new)
      }
    end

    ids = Cellect.Workflow.subject_set_ids(workflow_id)
    |> Enum.map(converter)
    |> Map.new

    cache.set(workflow_id, ids)

    noreply
  end

end
