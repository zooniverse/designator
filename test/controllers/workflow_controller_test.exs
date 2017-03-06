defmodule Designator.WorkflowControllerTest do
  use Designator.ConnCase

  alias Designator.Workflow

  setup %{conn: conn} do
    workflow = Repo.insert! %Workflow{}
    {:ok, [workflow: workflow, conn: put_req_header(conn, "accept", "application/json")]}
  end

  test "shows chosen resource", %{workflow: workflow, conn: conn} do
    conn = conn
    |> get(workflow_path(conn, :show, workflow))
    assert json_response(conn, 200) == []
  end

  test "reloads a workflow", %{workflow: workflow, conn: conn} do
    conn = conn
    |> http_basic_authenticate("username", "password")
    |> post(workflow_path(conn, :reload, workflow))
    assert response(conn, 204) == ""
  end

  test "unlocks a workflow reload", %{workflow: workflow, conn: conn} do
    conn = conn
    |> http_basic_authenticate("username", "password")
    |> post(workflow_path(conn, :unlock, workflow))
    assert response(conn, 204) == ""
  end

  test "marks a subject as retired", %{workflow: workflow, conn: conn} do
    conn = conn
    |> http_basic_authenticate("username", "password")
    |> post(workflow_path(conn, :remove, workflow, subject_id: 123))
    assert response(conn, 204) == ""
  end

  def http_basic_authenticate(conn, username, password) do
    put_req_header(conn, "authorization", "Basic " <> Base.encode64(username <> ":" <> password))
  end

end
