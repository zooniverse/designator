defmodule Designator.UserController do
  use Designator.Web, :controller

  plug BasicAuth, [callback: &Designator.Controllers.Helpers.authenticate/3] when action in [:add_seen_subjects]

  def add_seen_subjects(conn, %{"id" => user_id, "subject_ids" => subject_ids}) do
    render_blank(conn)
  end
end
