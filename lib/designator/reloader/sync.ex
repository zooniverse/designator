defmodule Designator.Reloader.Sync do
  use GenServer

  @behaviour Designator.Reloader

  def start_link() do
    GenServer.start_link(__MODULE__, {}, name: __MODULE__)
  end

  # This can't use GenServer.call because it's being used at a point when the SubjectSetCache process
  # is trying to update the same cache key. So the SubjectSetCache process has got a lock on that key,
  # and it's hold that lock until it receives a message back from this Sync process. But if this Sync
  # process needs to write back the results into the cache, it can't get a lock, and we get a deadlock.
  #
  # If we do the update directly rather than through GenServer.call, the code is executed within the
  # process space of the SubjectSetCache, which already has a lock on the cache, so it's fine if it
  # tries to write modifications.
  #
  # In order to keep this module compatible with Async, it needs to be a valid GenServer so that it
  # can be started into the process tree at boot, but after that we can't have it be used as a GenServer
  # in terms of sending messages.
  def reload_subject_set({workflow_id, subject_set_id}) do
    subject_ids = Designator.Workflow.subject_ids(workflow_id, subject_set_id) |> Array.from_list
    Designator.SubjectSetCache.set_subject_ids({workflow_id, subject_set_id}, subject_ids)
    :ok
  end
end
