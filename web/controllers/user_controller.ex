defmodule Designator.UserController do
  use Designator.Web, :controller

  plug BasicAuth, [callback: &Designator.Controllers.Helpers.authenticate/3] when action in [:add_seen_subjects]

  def add_seen_subjects(conn, %{"id" => user_id, "workflow_id" => workflow_id, "subject_ids" => subject_ids}) do
    { response_code, body} = process_request(workflow_id, user_id, subject_ids)

    render_json_response(conn, response_code, body)
  end

  def add_seen_subjects(conn, %{"id" => user_id, "workflow_id" => workflow_id, "subject_id" => subject_id}) do
    { response_code, body} = process_request(workflow_id, user_id, [subject_id])

    render_json_response(conn, response_code, body)
  end

  defp user_cache_key(workflow_id, user_id) do
    workflow_id = convert_to_int(workflow_id)
    user_id = convert_to_int(user_id)
    {workflow_id, user_id}
  end

  def process_request(workflow_id, user_id, subject_ids) do
    cast_subject_ids = subject_ids
      |> Enum.map(&(convert_to_int(&1)))

    invalid_integer_params = Enum.any?(cast_subject_ids, &is_invalid_integer(&1))
    if invalid_integer_params do
      { 422, Poison.encode!(%{errors: "invalid subject id supplied, must be a valid integer"}) }
    else
      cache_key = user_cache_key(workflow_id, user_id)
      response_code = add_subject_ids_to_seens(cache_key, cast_subject_ids)
      { response_code, [] }
    end
  end

  defp add_subject_ids_to_seens(user_cache_key, subject_ids) do
    case Designator.UserCache.add_seen_ids(user_cache_key, subject_ids) do
      {:error, :not_existing} -> # user not loaded ignore the incoming request
        201
      :ok -> # update the existing user data
        204
    end
  end
end
