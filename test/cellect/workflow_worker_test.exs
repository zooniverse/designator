defmodule WorkflowWorkerTest do
  use ExUnit.Case

  test "smoke" do
    {:ok, pid} = Cellect.WorkflowWorker.start_link(338)
    ids = Cellect.WorkflowWorker.select_randomly(pid)
    assert length(ids) == 45263
  end
end
