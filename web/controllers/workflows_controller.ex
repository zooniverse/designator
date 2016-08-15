defmodule Cellect.WorkflowsController do
  use Cellect.Web, :controller

  def index(conn, %{"workflow_id" => workflow_id} = params) do

    {workflow_id, _} = Integer.parse(workflow_id)
    user_id = get_integer_param(params, "user_id", nil)
    strategy = Map.get(params, "strategy", "uniform")
    limit = get_integer_param(params, "limit", 5)

    subjects = Cellect.Selection.select(strategy, workflow_id, user_id)
    render conn, "index.json", subjects: subjects
  end

  def reload(conn, %{"workflow_id" => workflow_id}) do
    Cellect.Cache.SubjectIds.reload_async()
    send_resp(conn, 204, [])
  end

  def retire(conn, %{"workflow_id" => workflow_id, "subject_id" => subject_id}) do
    # TODO: If this is too slow, implement a temporary in-memory list
    Cellect.Cache.SubjectIds.reload_async()
    send_resp(conn, 204, [])
  end

  defp get_integer_param(params, key, default) do
    if Map.has_key?(params, key) do
      {value, _} = Integer.parse(Map.get(params, key))
      value
    else
      default
    end
  end
end
