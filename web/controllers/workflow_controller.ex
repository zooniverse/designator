defmodule Cellect.WorkflowController do
  use Cellect.Web, :controller

  def show(conn, %{"id" => workflow_id} = params) do
    {workflow_id, _} = Integer.parse(workflow_id)
    user_id = get_integer_param(params, "user_id", nil)
    strategy = Map.get(params, "strategy", "uniform")
    limit = get_integer_param(params, "limit", 5)

    subjects = Cellect.Selection.select(strategy, workflow_id, user_id, limit)
    render conn, "show.json", subjects: subjects
  end

  def reload(conn, %{"id" => workflow_id}) do
    {workflow_id, _} = Integer.parse(workflow_id)
    Cellect.Cache.SubjectIds.reload_async(workflow_id)
    send_resp(conn, 204, [])
  end

  def unlock(conn, %{"id" => workflow_id}) do
    {workflow_id, _} = Integer.parse(workflow_id)
    Cellect.Cache.SubjectIds.unlock_reload(workflow_id)
    send_resp(conn, 204, [])
  end

  def remove(conn, %{"id" => workflow_id, "subject_id" => subject_id}) do
    # TODO: If this is too slow, implement a temporary in-memory list
    {workflow_id, _} = Integer.parse(workflow_id)
    Cellect.Cache.SubjectIds.reload_async(workflow_id)
    send_resp(conn, 204, [])
  end
  def remove(conn, %{"id" => workflow_id}) do
    {workflow_id, _} = Integer.parse(workflow_id)
    Cellect.Cache.SubjectIds.reload_async(workflow_id)
    send_resp(conn, 204, [])
  end

  defp get_integer_param(params, key, default) do
    case Map.get(params, key) do
      nil -> default
      value ->
        {int, _} = Integer.parse(value)
        int
      _ ->
        default
    end
  end
end