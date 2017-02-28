defmodule Cellect.UserCache do
  use GenServer

  @registry_name :user_cache_registry
  @process_timeout 10000 # 3_600_000 # 1 hour in milliseconds

  defstruct [:workflow_id, :user_id, :seen_ids, :reloading]

  def start_link(workflow_user) do
    GenServer.start_link(__MODULE__, [workflow_user], name: via_tuple(workflow_user))
  end

  def get(workflow_user) do
    GenServer.call(via_tuple(workflow_user), :get)
  end

  def set(workflow_user, seen_ids) do
    GenServer.cast(via_tuple(workflow_user), {:set_seen_ids, seen_ids})
  end

  defp via_tuple(workflow_user) do
    {:via, Registry, {@registry_name, workflow_user}}
  end

  ### SERVER

  def init([{workflow_id, user_id}]) do
    seen_ids = Cellect.User.seen_subject_ids(workflow_id, user_id) |> Enum.into(MapSet.new)

    state = %__MODULE__{
      workflow_id: workflow_id,
      user_id: user_id,
      seen_ids: seen_ids,
      reloading: false
    }

    {:ok, state, @process_timeout}
  end

  def handle_call(:get, _from, state) do
    {:reply, state, state, @process_timeout}
  end

  def handle_cast({:set_seen_ids, seen_ids}, state) do
    new_state = %__MODULE__{ state | seen_ids: seen_ids}
    {:noreply, new_state, @process_timeout}
  end

  def handle_info(:timeout, state) do
    {:stop, :process_expired, state}
  end
end
