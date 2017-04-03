defmodule Designator.StatusController do
  use Designator.Web, :controller

  def index(conn, _params) do
    status = %{
      workflows: Designator.WorkflowCache.status,
      subject_sets: Designator.SubjectSetCache.status,
      users: Designator.UserCache.status,
      recently_retired: Designator.RecentlyRetired.status
    }

    render conn, "index.json", status: status
  end
end
