defmodule Designator.Reloader do
  @doc "Updates the cached list of unretired subject ids for a given {workflow_id, subject_id}"
  @callback reload_subject_set({workflow_id :: integer, subject_set_id :: integer}) :: any
end
