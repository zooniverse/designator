defmodule Cellect.WorkflowControllerTest do
  use Cellect.ConnCase

  import Mock

  alias Cellect.Workflow
  @valid_attrs %{}
  @invalid_attrs %{}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  test "shows chosen resource", %{conn: conn} do
    with_mock Cellect.Cache.Reloader, [reload_subject_set: fn(_) -> :ok end] do
      workflow = Repo.insert! %Workflow{}
      conn = get conn, workflow_path(conn, :show, workflow)
      assert json_response(conn, 200) == []
    end
  end

  test "reloads a workflow", %{conn: conn} do
    with_mock Cellect.Cache.Reloader, [reload_subject_set: fn(_) -> :ok end] do
      workflow = Repo.insert! %Workflow{}
      conn = post conn, workflow_path(conn, :reload, workflow)
      assert response(conn, 204) == ""
    end
  end

  test "unlocks a workflow reload", %{conn: conn} do
    with_mock Cellect.Cache.Reloader, [reload_subject_set: fn(_) -> :ok end] do
      workflow = Repo.insert! %Workflow{}
      conn = post conn, workflow_path(conn, :unlock, workflow)
      assert response(conn, 204) == ""
    end
  end

  test "marks a subject as retired", %{conn: conn} do
    with_mock Cellect.Cache.Reloader, [reload_subject_set: fn(_) -> :ok end] do
      workflow = Repo.insert! %Workflow{}
      conn = post conn, workflow_path(conn, :remove, workflow, subject_id: 123)
      assert response(conn, 204) == ""
    end
  end
end
