defmodule Designator.Router do
  use Designator.Web, :router
  use Plug.ErrorHandler

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", Designator do
    pipe_through :api

    get "/", RootController, :index
  end

  scope "/api", Designator do
    pipe_through :api

    get "/", StatusController, :index
    resources "/workflows", WorkflowController

    post "/workflows/:id/reload", WorkflowController, :reload
    post "/workflows/:id/unlock", WorkflowController, :unlock
    post "/workflows/:id/remove", WorkflowController, :remove

    put "/users/:id/add_seen_subjects", UserController, :add_seen_subjects
    put "/users/:id/add_seen_subject", UserController, :add_seen_subject
  end

  # Ignore Phoenix routing errors
  defp handle_errors(_conn, %{reason: %Phoenix.Router.NoRouteError{}}), do: :ok

  # report other request errors to rollbar
  defp handle_errors(conn, %{kind: kind, reason: reason, stack: stacktrace}) do
    Rollbax.report(kind, reason, stacktrace)
    # currently this reports to Rollbar and raises a standar 500 error message
    # "Server internal error"
    #
    # uncomment the following to return a custom error message containing the error
    # though take care not to leak information from internal messages
    # use `debug_errors: true` for development error reporting
    #
    # message = reason.message || "Server internal error"
    # json(conn, %{errors: %{detail: message}})
  end
end
