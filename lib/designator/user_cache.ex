defmodule Designator.UserCache do
  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, [])
  end

  def init([]) do
    children = [
      supervisor(ConCache, [[ttl_check: :timer.seconds(30),
                             ttl: :timer.minutes(15),
                             touch_on_read: true],
                            [name: :user_cache]]),
    ]

    supervise(children, strategy: :one_for_one)
  end

  ### Public API

  defstruct [:workflow_id, :user_id, :configuration, :seen_ids, :recently_selected_ids, :reloading]

  def status do
    :user_cache
    |> ConCache.ets
    |> :ets.tab2list
    |> Enum.map(fn({_, val}) ->
      %{workflow_id: val.workflow_id,
        user_id: val.user_id,
        seen_size: MapSet.size(val.seen_ids),
        recently_selected_size: MapSet.size(val.recently_selected_ids)
       }
    end)
  end

  def get({workflow_id, nil}) do
    %__MODULE__{
      workflow_id: workflow_id,
      user_id: nil,
      configuration: %{},
      seen_ids: MapSet.new,
      recently_selected_ids: MapSet.new,
      reloading: false
    }
  end

  def get({workflow_id, user_id} = workflow_user) do
    ConCache.get_or_store(:user_cache, workflow_user, fn() ->
      configuration = Designator.User.configuration(workflow_id, user_id)
      seen_ids = Designator.User.seen_subject_ids(workflow_id, user_id) |> Enum.into(MapSet.new)

      %__MODULE__{
        workflow_id: workflow_id,
        user_id: user_id,
        configuration: configuration,
        seen_ids: seen_ids,
        recently_selected_ids: MapSet.new,
        reloading: false
      }
    end)
  end

  def set({workflow_id, user_id} = workflow_user, user_cache) do
    ConCache.update(:user_cache, workflow_user, fn(old_user_cache) ->
      case old_user_cache do
        nil ->
          {:ok , Map.merge(%__MODULE__{workflow_id: workflow_id, user_id: user_id}, user_cache)}
        val ->
          {:ok, Map.merge(val, user_cache)}
      end
    end)
  end

  def add_recently_selected(%{workflow_id: workflow_id, user_id: user_id}, subject_ids), do: add_recently_selected({workflow_id, user_id}, subject_ids)
  def add_recently_selected({_, nil}, _), do: :ok
  def add_recently_selected(key, subject_ids) do
    ConCache.update_existing(:user_cache, key, fn (user) ->
      recently_selected_ids = MapSet.union(user.recently_selected_ids, MapSet.new(subject_ids))

      {:ok, %__MODULE__{user | recently_selected_ids: recently_selected_ids}}
    end)
  end
end
