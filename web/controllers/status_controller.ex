defmodule Cellect.StatusController do
  use Cellect.Web, :controller

  def index(conn, _params) do
    status = %{
      workflows: Cellect.WorkflowCache.status,
      subject_sets: Cellect.SubjectSetCache.status,
      users: Cellect.UserCache.status
    }

    render conn, "index.json", status: status
  end
end
