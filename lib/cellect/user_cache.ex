defmodule Cellect.UserCache do
  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, [])
  end

  def init([]) do
    children = [
      supervisor(ConCache, [[ttl_check: :timer.seconds(1),
                             ttl: :timer.minutes(5),
                             touch_on_read: true],
                            [name: :user_cache]]),
    ]

    supervise(children, strategy: :one_for_one)
  end

  ### Public API

  defstruct [:workflow_id, :user_id, :seen_ids, :recently_selected_ids, :reloading]

  def get({workflow_id, user_id} = workflow_user) do
    ConCache.get_or_store(:user_cache, workflow_user, fn() ->
      seen_ids = Cellect.User.seen_subject_ids(workflow_id, user_id) |> Enum.into(MapSet.new)

      %__MODULE__{
        workflow_id: workflow_id,
        user_id: user_id,
        seen_ids: seen_ids,
        recently_selected_ids: MapSet.new,
        reloading: false
      }
    end)
  end

  def add_recently_selected(%{workflow_id: workflow_id, user_id: user_id}, subject_ids), do: add_recently_selected({workflow_id, user_id}, subject_ids)
  def add_recently_selected(key, subject_ids) do
    ConCache.update_existing(:user_cache, key, fn (user) ->
      recently_selected_ids = MapSet.union(user.recently_selected_ids, MapSet.new(subject_ids))

      {:ok, %__MODULE__{user | recently_selected_ids: recently_selected_ids}}
    end)
  end
end
