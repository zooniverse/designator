defmodule Designator.CacheCase do
  @moduledoc """
  This module defines the test case to be used by
  tests that interact with the caches.
  """

  use ExUnit.CaseTemplate

  using do
    quote do
      # Import conveniences for testing with connections
      use Phoenix.ConnTest

      alias Designator.Repo
      alias Designator.Workflow
      alias Designator.UserSeenSubject
      alias Designator.WorkflowCache
      alias Designator.SubjectSetCache

      import Ecto
      import Ecto.Changeset
      import Ecto.Query, only: [from: 1, from: 2]
    end
  end

  setup tags do
    clear_cache(:workflow_cache)
    clear_cache(:user_cache)
    clear_cache(:subject_set_cache)
    clear_cache(:recently_retired_cache)

    :ok
  end

  def clear_cache(cache_name) do
    cache_name
    |> ConCache.ets
    |> :ets.tab2list
    |> Enum.each(fn({key, _}) -> ConCache.delete(cache_name, key) end)
  end
end
