defmodule Cellect.UserCacheSupervisor do
  use Supervisor

  @registry_name :user_cache_registry

  def start_link do
    Supervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  def find_or_create_process(workflow_id, user_id) do
    tuple = {workflow_id, user_id}
    if alive?(tuple) do
      {:ok, tuple}
    else
      create_process(tuple)
    end
  end

  def alive?(tuple) do
    case Registry.lookup(@registry_name, tuple) do
      [] -> false
      _ -> true
    end
  end

  def create_process(tuple) do
    case Supervisor.start_child(__MODULE__, [tuple]) do
      {:ok, pid} -> {:ok, tuple}
      {:error, {:already_started, _pid}} -> {:error, :process_already_exists}
      other -> {:error, other}
    end
  end

  def init(_) do
    children = [
      worker(Cellect.UserCache, [], restart: :temporary)
    ]

    supervise(children, strategy: :simple_one_for_one)
  end
end
