defmodule Cellect.WorkflowManager do
  def start_link do
    Agent.start_link(fn -> %{} end)
  end

  def worker(pid, workflow_id) do
    worker_pid = Agent.get(pid, fn pids -> pids[workflow_id] end)

    case worker_pid do
      nil ->
        {:ok, worker_pid} = Cellect.WorkflowWorker.start_link(workflow_id)
        Agent.update(pid, fn pids -> Map.put(pids, workflow_id, worker_pid) end)
        worker_pid
      _ ->
        worker_pid
    end
  end
end
