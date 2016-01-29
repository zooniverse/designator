defmodule Cellect.UserSeen.Manager do
  use GenServer

  def start_link do
    GenServer.start_link(__MODULE__, :ok, [])
  end

  def worker(server, workflow_id, user_id) do
    GenServer.call(server, {:upsert, workflow_id, user_id})
  end

  ## Server callbacks

  def init(:ok) do
    pids = %{}
    refs = %{}
    {:ok, {pids, refs}}
  end

  def handle_call({:upsert, workflow_id, user_id}, _from, {pids, refs} = state) do
    key = {workflow_id, user_id}

    if Map.has_key?(pids, key) do
      {:ok, pid} = Map.fetch(pids, key)
      {:reply, pid, state}
    else
      {:ok, pid} = Cellect.UserSeen.Supervisor.start_worker(workflow_id, user_id)
      ref = Process.monitor(pid)
      refs = Map.put(refs, ref, key)
      pids = Map.put(pids, key, pid)

      {:reply, pid, {pids, refs}}
    end
  end

  # Remove a worker if it crashes or stops
  def handle_info({:DOWN, ref, :process, _pid, reason}, {pids, refs}) do
    IO.puts "Oh no, something crashed"

    {key, refs} = Map.pop(refs, ref)
    {pid, pids} = Map.pop(pids, key)

    {:noreply, {pids, refs}}
  end

  def handle_info(_msg, state) do
    {:noreply, state}
  end
end
