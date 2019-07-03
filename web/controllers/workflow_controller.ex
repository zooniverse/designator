defmodule Designator.WorkflowController do
  use Designator.Web, :controller

  plug BasicAuth, [callback: &Designator.Controllers.Helpers.authenticate/3] when action in [:reload, :unlock, :remove]

  def show(conn, %{"id" => workflow_id} = params) do
    {workflow_id, _} = Integer.parse(workflow_id)
    user_id = get_integer_param(params, "user_id", nil)
    subject_set_id = get_integer_param(params, "subject_set_id", nil)
    limit = get_integer_param(params, "limit", 5)

    subjects = Designator.Selection.select(
      workflow_id,
      user_id,
      [ subject_set_id: subject_set_id, limit: limit ]
    )
    Logger.metadata([selected_ids: Enum.join(subjects, ",")])
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

  # subject_id can be a URL query param (byte sequence)
  def remove(conn, %{"id" => workflow_id, "subject_id" => subject_id}) when is_binary(subject_id) do
    {workflow_id, _} = Integer.parse(workflow_id)
    {subject_id, _} = Integer.parse(subject_id)
    do_remove(conn, workflow_id, subject_id)
  end
  # subject_id can be come from POST JSON payload
  def remove(conn, %{"id" => workflow_id, "subject_id" => subject_id}) when is_integer(subject_id) do
    {workflow_id, _} = Integer.parse(workflow_id)
    do_remove(conn, workflow_id, subject_id)
  end

  defp do_remove(conn, workflow_id, subject_id) do
    Designator.RecentlyRetired.add(workflow_id, subject_id)

    # Refresh the current known state from the source datastore
    # to ensure the system is operating efficiently on updated lists of
    # available subject_ids and retired subject_ids
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
end
