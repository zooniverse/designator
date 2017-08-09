defmodule Designator.Application do
  use Application

  @reloader Application.get_env(:designator, :reloader)

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      supervisor(DesignatorWeb.Endpoint, []),
      supervisor(Designator.Repo, []),
      supervisor(Designator.WorkflowCache, []),
      supervisor(Designator.SubjectSetCache, []),
      supervisor(Designator.UserCache, []),
      supervisor(Designator.RecentlyRetired, []),
      worker(@reloader, [])
    ]

    opts = [strategy: :one_for_one, name: Designator.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def config_change(changed, _new, removed) do
    Designator.Endpoint.config_change(changed, removed)
    :ok
  end
end
