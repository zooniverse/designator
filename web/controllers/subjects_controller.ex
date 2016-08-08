defmodule Cellect.SubjectsController do
  use Cellect.Web, :controller

  def index(conn, %{"strategy" => strategy, "workflow_id" => workflow_id, "user_id" => user_id}) do
    subjects = Cellect.Selection.select(strategy, workflow_id, user_id)
    render conn, "index.json", subjects: subjects
  end
end
