defmodule Cellect.Router do
  use Cellect.Web, :router
  use Plug.ErrorHandler

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", Cellect do
    pipe_through :api

    get  "/workflows/:workflow_id", WorkflowsController, :index
    post "/workflows/:workflow_id/reload", WorkflowsController, :reload
    put  "/workflows/:workflow_id/remove", WorkflowsController, :retire
  end

  defp handle_errors(conn, %{kind: kind, reason: reason, stack: stacktrace}) do
    Rollbax.report(kind, reason, stacktrace)
  end
end

