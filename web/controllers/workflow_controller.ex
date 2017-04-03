defmodule Designator.WorkflowController do
  use Designator.Web, :controller

  plug BasicAuth, [callback: &Designator.WorkflowController.authenticate/3] when action in [:reload, :unlock, :remove]

  def show(conn, %{"id" => workflow_id} = params) do
    {workflow_id, _} = Integer.parse(workflow_id)
    user_id = get_integer_param(params, "user_id", nil)
    strategy = Map.get(params, "strategy", "uniform")
    limit = get_integer_param(params, "limit", 5)

    subjects = Designator.Selection.select(strategy, workflow_id, user_id, limit)
    render conn, "show.json", subjects: subjects
  end

  def reload(conn, %{"id" => workflow_id}) do
    {workflow_id, _} = Integer.parse(workflow_id)
    do_full_reload(workflow_id)
    send_resp(conn, 204, [])
  end

  def unlock(conn, %{"id" => workflow_id}) do
    {workflow_id, _} = Integer.parse(workflow_id)
    Designator.WorkflowCache.get(workflow_id).subject_set_ids
    |> Enum.each(fn subject_set_id -> Designator.SubjectSetCache.unlock({workflow_id, subject_set_id}) end)
    send_resp(conn, 204, [])
  end

  def remove(conn, %{"id" => workflow_id, "subject_id" => subject_id}) when is_binary(subject_id) do
    {workflow_id, _} = Integer.parse(workflow_id)
    {subject_id, _} = Integer.parse(subject_id)
    do_remove(conn, workflow_id, subject_id)
  end
  def remove(conn, %{"id" => workflow_id, "subject_id" => subject_id}) when is_integer(subject_id) do
    {workflow_id, _} = Integer.parse(workflow_id)
    do_remove(conn, workflow_id, subject_id)
  end
  def remove(conn, %{"id" => workflow_id}) do
    {workflow_id, _} = Integer.parse(workflow_id)
    do_full_reload(workflow_id)
    send_resp(conn, 204, [])
  end

  defp do_remove(conn, workflow_id, subject_id) do
    Designator.RecentlyRetired.add(workflow_id, subject_id)

    if MapSet.size(Designator.RecentlyRetired.get(workflow_id).subject_ids) > 50 do
      do_full_reload(workflow_id)
    end

    send_resp(conn, 204, [])
  end

  defp get_integer_param(params, key, default) do
    case Map.get(params, key) do
      nil -> default
      value ->
        {int, _} = Integer.parse(value)
        int
    end
  end

  defp do_full_reload(workflow_id) do
    Designator.RecentlyRetired.clear(workflow_id)
    Designator.WorkflowCache.reload(workflow_id)
    Designator.WorkflowCache.get(workflow_id).subject_set_ids
    |> Enum.each(fn subject_set_id -> Designator.SubjectSetCache.reload({workflow_id, subject_set_id}) end)
  end

  def authenticate(conn, username, password) do
    desired_username = Application.fetch_env!(:designator, :api_auth)[:username]
    desired_password = Application.fetch_env!(:designator, :api_auth)[:password]

    if username == desired_username && password == desired_password do
      conn
    else
      conn
      |> Plug.Conn.halt
    end
  end
end
