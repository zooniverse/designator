defmodule Cellect.WorkflowCacheTest do
  use Cellect.ConnCase
  use Cellect.CacheCase

  describe "reloading" do
    test "reloads configuration" do
      {:ok, workflow} = Workflow.changeset(%Workflow{}, %{configuration: %{a: 1}}) |> Repo.insert
      assert WorkflowCache.get(workflow.id).configuration == %{"a" => 1}

      {:ok, _} = Workflow.changeset(workflow, %{configuration: %{a: 2}}) |> Repo.update
      assert WorkflowCache.get(workflow.id).configuration == %{"a" => 1}

      WorkflowCache.reload(workflow.id)
      assert WorkflowCache.get(workflow.id).configuration == %{"a" => 2}
    end
  end
end
