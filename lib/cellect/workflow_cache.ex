defmodule Cellect.WorkflowCache do
  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, [])
  end

  def init([]) do
    children = [
      supervisor(ConCache, [[ttl_check: :timer.seconds(1),
                            ttl: :timer.seconds(5),
                            touch_on_read: true],
                            [name: :workflow_cache]]),
    ]

    supervise(children, strategy: :one_for_one)
  end

  ### Public API

  def get(workflow_id) do
    ConCache.get_or_store(:workflow_cache, workflow_id, fn() ->
      Cellect.Workflow.find(workflow_id)
    end)
  end
end
