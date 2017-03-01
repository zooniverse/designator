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

    noreply()
  end
  
  defcast reload_subject_set({workflow_id, subject_set_id}), state: state do
    subject_ids = Cellect.Workflow.subject_ids(workflow_id, subject_set_id) |> Array.from_list
    Cellect.SubjectSetCache.set_subject_ids({workflow_id, subject_set_id}, subject_ids)
    noreply()
  end

  defcast reload_user_seens(cache, workflow_id, user_id) do
    seen_subject_ids = Cellect.User.seen_subject_ids(workflow_id, user_id) |> Enum.into(MapSet.new)
    cache.set({workflow_id, user_id}, seen_subject_ids)
    noreply()
  end
end
