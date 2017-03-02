defmodule Cellect do
  use Application

  @reloader Application.get_env(:cellect, :reloader)

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      supervisor(Cellect.Endpoint, []),
      supervisor(Cellect.Repo, []),
      supervisor(Cellect.WorkflowCache, []),
      supervisor(Cellect.SubjectSetCache, []),
      supervisor(Cellect.UserCache, []),
      worker(@reloader, [])
    ]

    opts = [strategy: :one_for_one, name: Cellect.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def config_change(changed, _new, removed) do
    Cellect.Endpoint.config_change(changed, removed)
    :ok
  end
end
