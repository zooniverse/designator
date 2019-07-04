defmodule Designator.UserController do
  use Designator.Web, :controller

  plug BasicAuth, [callback: &Designator.Controllers.Helpers.authenticate/3] when action in [:add_seen_subjects]

  def add_seen_subjects(conn, %{"id" => user_id, "workflow_id" => workflow_id, "subject_ids" => subject_ids}) do
    user_id = convert_to_int(user_id)
    workflow_id = convert_to_int(workflow_id)
    user_cache_key = {workflow_id, user_id}
    {workflow_id, user_id}

    # TODO: do we have to ensure a list of subject id ints?
    # {subject_ids, _} = subject_ids
    # |> Enum.map(&(Integer.parse(&1)))
    # require IEx; IEx.pry
    # Designator.UserCache.get(user_cache_key)

    response_code =
      case Designator.UserCache.add_seen_ids(user_cache_key, subject_ids) do
        {:error, :not_existing} -> # user not loaded, ignoring
          201
        :ok -> # update the existing user data
          204
      end

    conn
    |> send_resp(response_code, "")
  end
end
