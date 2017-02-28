defmodule Cellect.UserCache do
  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, [])
  end

  def init([]) do
    children = [
      supervisor(ConCache, [[ttl_check: :timer.seconds(1),
                             ttl: :timer.seconds(5),
                             touch_on_read: true],
                            [name: :user_cache]]),
    ]

    supervise(children, strategy: :one_for_one)
  end

  ### Public API

  defstruct [:workflow_id, :user_id, :seen_ids, :reloading]

  def get({workflow_id, user_id} = workflow_user) do
    ConCache.get_or_store(:user_cache, workflow_user, fn() ->
      seen_ids = Cellect.User.seen_subject_ids(workflow_id, user_id) |> Enum.into(MapSet.new)

      %__MODULE__{
        workflow_id: workflow_id,
        user_id: user_id,
        seen_ids: seen_ids,
        reloading: false
      }
    end)
  end
end
