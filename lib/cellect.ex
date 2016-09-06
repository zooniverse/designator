defmodule Cellect do
  use Application

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      supervisor(Cellect.Endpoint, []),
      supervisor(Cellect.Repo, []),
      worker(Cellect.Cache.Reloader, []),
      worker(Cellect.Cache.SubjectIds, [])

      # supervisor(Cellect.Workflow.Supervisor, [])
      # supervisor(Cellect.UserSeen.Supervisor, [])
      # supervisor(Cellect.SubjectSets.Supervisor, [])
      # supervisor(Cellect.Retireds.Supervisor, [])
      # Here you could define other workers and supervisors as children
      # worker(Cellect.Worker, [arg1, arg2, arg3]),
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Cellect.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    Cellect.Endpoint.config_change(changed, removed)
    :ok
  end
end
