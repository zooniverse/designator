defmodule Cellect.WorkflowControllerTest do
  use Cellect.ConnCase

  alias Cellect.Workflow

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  test "shows chosen resource", %{conn: conn} do
    workflow = Repo.insert! %Workflow{}
    conn = get conn, workflow_path(conn, :show, workflow)
    assert json_response(conn, 200) == []
  end

  test "reloads a workflow", %{conn: conn} do
    workflow = Repo.insert! %Workflow{}
    conn = post conn, workflow_path(conn, :reload, workflow)
    assert response(conn, 204) == ""
  end

  test "unlocks a workflow reload", %{conn: conn} do
    workflow = Repo.insert! %Workflow{}
    conn = post conn, workflow_path(conn, :unlock, workflow)
    assert response(conn, 204) == ""
  end

  test "marks a subject as retired", %{conn: conn} do
    workflow = Repo.insert! %Workflow{}
    conn = post conn, workflow_path(conn, :remove, workflow, subject_id: 123)
    assert response(conn, 204) == ""
  end
end
