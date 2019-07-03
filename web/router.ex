defmodule Designator.Router do
  use Designator.Web, :router
  use Plug.ErrorHandler

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", Designator do
    pipe_through :api

    get "/", StatusController, :index
    resources "/workflows", WorkflowController

    post "/workflows/:id/reload", WorkflowController, :reload
    post "/workflows/:id/unlock", WorkflowController, :unlock
    post "/workflows/:id/remove", WorkflowController, :remove

    put "/users/:id/add_seen_subjects", UserController, :add_seen_subjects
  end

  defp handle_errors(conn, %{kind: kind, reason: reason, stack: stacktrace}) do
    Rollbax.report(kind, reason, stacktrace)
    case Poison.encode(%{kind: kind, reason: reason}) do
      {:ok, json} ->
        send_resp(conn, conn.status, json)
      _ ->
        send_resp(conn, conn.status, "Something went wrong")
    end
  end
end

