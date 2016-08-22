defmodule Cellect.UserSeen.Worker do
  use GenServer

  def start_link(workflow_id, user_id) do
    seen_ids = Cellect.Subject.seen_ids(workflow_id, user_id)
    seen_set = Enum.into(seen_ids, HashSet.new)

    GenServer.start_link __MODULE__, seen_set
  end

  def get(pid) do
    GenServer.call pid, :get
  end

  def add(pid, seen_id) do
    GenServer.cast pid, {:add, seen_id}
  end

  ####
  # Genserver implementation

  def handle_call(:get, _from, seen_set) do
    {:reply, seen_set, seen_set}
  end

  def handle_cast({:add, seen_id}, _from, seen_set) do
    {:noreply, Set.put(seen_set, seen_id)}
  end
end
