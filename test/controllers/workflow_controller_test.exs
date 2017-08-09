defmodule Designator.WorkflowControllerTest do
  use DesignatorWeb.ConnCase

  @username Application.fetch_env!(:designator, :api_auth)[:username]
  @password Application.fetch_env!(:designator, :api_auth)[:password]

  alias Designator.Workflow

  setup %{conn: conn} do
    workflow = Repo.insert! %Workflow{}
    {:ok, [workflow: workflow, conn: put_req_header(conn, "accept", "application/json")]}
  end

  describe "getting subjects" do
    test "shows chosen resource", %{workflow: workflow, conn: conn} do
      conn = conn
      |> get(workflow_path(conn, :show, workflow))
      assert json_response(conn, 200) == []
    end
  end

  describe "reloading a workflow" do
    test "reloads a workflow", %{workflow: workflow, conn: conn} do
      conn = conn
      |> http_basic_authenticate(@username, @password)
      |> post(workflow_path(conn, :reload, workflow))
      assert response(conn, 204) == ""
    end

    test "requires authentication", %{workflow: workflow, conn: conn} do
      conn = conn
      |> post(workflow_path(conn, :reload, workflow))
      assert response(conn, 401) == "401 Unauthorized"
    end
  end

  describe "unlocking reloads for a workflow" do
    test "unlocks a workflow reload", %{workflow: workflow, conn: conn} do
      conn = conn
      |> http_basic_authenticate(@username, @password)
      |> post(workflow_path(conn, :unlock, workflow))
      assert response(conn, 204) == ""
    end

    test "requires authentication", %{workflow: workflow, conn: conn} do
      conn = conn
      |> post(workflow_path(conn, :unlock, workflow))
      assert response(conn, 401) == "401 Unauthorized"
    end
  end

  describe "marking a subject as retired" do
    test "marks a subject as retired", %{workflow: workflow, conn: conn} do
      conn = conn
      |> http_basic_authenticate(@username, @password)
      |> post(workflow_path(conn, :remove, workflow, subject_id: 123))
      assert response(conn, 204) == ""

      cache = Designator.RecentlyRetired.get(workflow.id)
      assert cache.subject_ids == MapSet.new([123])
    end

    test "requires authentication", %{workflow: workflow, conn: conn} do
      conn = conn
      |> post(workflow_path(conn, :remove, workflow, subject_id: 123))
      assert response(conn, 401) == "401 Unauthorized"
    end
  end

  def http_basic_authenticate(conn, username, password) do
    put_req_header(conn, "authorization", "Basic " <> Base.encode64(username <> ":" <> password))
  end
end
