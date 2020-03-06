defmodule Designator.RootController do
  use Designator.Web, :controller

  def index(conn, _params) do
    status = %{
      status: :ok,
      revision: Application.get_env(:designator, :revision)
    }
    render conn, "index.json", status: status
  end
end
