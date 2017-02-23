defmodule Cellect.StatusController do
  use Cellect.Web, :controller

  def index(conn, _params) do
    status = Cellect.Cache.SubjectIds.status()
    render conn, "index.json", status: status
  end
end
