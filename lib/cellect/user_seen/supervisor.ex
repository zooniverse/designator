defmodule Cellect.UserSeen.Supervisor do
  use Supervisor

  @name Cellect.UserSeen.Supervisor

  def start_link() do
    Supervisor.start_link(__MODULE__, :ok, name: @name)
  end

  def start_worker(workflow_id, user_id) do
    Supervisor.start_child(@name, [workflow_id, user_id])
  end

  def init(:ok) do
    children = [
      worker(Cellect.UserSeen.Worker, [], restart: :temporary)
    ]

    supervise(children, strategy: :simple_one_for_one)
  end
end
