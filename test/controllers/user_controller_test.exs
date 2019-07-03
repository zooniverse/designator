defmodule Designator.UserControllerTest do
  use Designator.ConnCase

  @username Application.fetch_env!(:designator, :api_auth)[:username]
  @password Application.fetch_env!(:designator, :api_auth)[:password]

  alias Designator.User

  setup %{conn: conn} do
    workflow_id =  1
    user_id = 2
    {
      :ok,
      [
        user: Designator.UserCache.get({workflow_id, user_id}),
        workflow_id: workflow_id,
        conn: put_req_header(conn, "accept", "application/json")
      ]
    }
  end

  def add_seens_path(user_id) do
    "/api/users/#{:user_id}/add_seen_subjects"
  end

  def http_basic_authenticate(conn, username, password) do
    put_req_header(conn, "authorization", "Basic " <> Base.encode64(username <> ":" <> password))
  end

  @tag :wip
  describe "adding a known user seen subjects for a workflow" do
    test "requires authentication", %{user: user, workflow_id: workflow_id, conn: conn} do
      conn_response = conn
      |> put(add_seens_path(user.user_id), workflow_id: workflow_id, subject_ids: '1')
      assert response(conn_response, 401) == "401 Unauthorized"
    end

    test "respons with a 201 created response code", %{user: user, workflow_id: workflow_id, conn: conn} do
      conn_response = conn
      |> http_basic_authenticate(@username, @password)
      |> put(add_seens_path(user.user_id), workflow_id: workflow_id, subject_ids: '1')
      assert response(conn_response, 201) == ""
    end

    test "respons with a 204 no-content response code for loaded users", %{user: user, workflow_id: workflow_id, conn: conn} do
      Designator.UserCache.set(
        { workflow_id, user.user_id },
        %{
          seen_ids: MapSet.new([1]),
          recently_selected_ids: MapSet.new,
          configuration: %{}
        }
      )
      conn_response = conn
      |> http_basic_authenticate(@username, @password)
      |> put(add_seens_path(user.user_id), workflow_id: workflow_id, subject_ids: '1')
      assert response(conn_response, 204) == ""
    end

    test "adds the subject ids", %{user: user, workflow_id: workflow_id, conn: conn} do
      conn_response = conn
      |> http_basic_authenticate(@username, @password)
      |> put(add_seens_path(user.user_id), workflow_id: workflow_id, subject_ids: '1')
      assert response(conn_response, 201) == ""
      user = Designator.UserCache.get({workflow_id, user.user_id})
      assert user.seen_ids == MapSet.new([1])
    end

    test "adds the subject ids when using the subject_id param", %{user: user, workflow_id: workflow_id, conn: conn} do
      conn_response = conn
      |> http_basic_authenticate(@username, @password)
      |> put(add_seens_path(user.user_id), workflow_id: workflow_id, subject_id: '1,2,3')
      assert response(conn_response, 201) == ""
      user = Designator.UserCache.get({workflow_id, user.user_id})
      assert user.seen_ids == MapSet.new([1,2,3])
    end

    test "adds subject ids listed as comma delimited string", %{user: user, workflow_id: workflow_id, conn: conn} do
      conn_response = conn
      |> http_basic_authenticate(@username, @password)
      |> put(add_seens_path(user.user_id), workflow_id: workflow_id, subject_ids: '1,2,3')
      assert response(conn_response, 201) == ""
      user = Designator.UserCache.get({workflow_id, user.user_id})
      assert user.seen_ids == MapSet.new([1,2,3])
    end

    test "does not duplicate subject ids", %{user: user, workflow_id: workflow_id, conn: conn} do
      Designator.UserCache.set(
        { workflow_id, user.user_id },
        %{
          seen_ids: MapSet.new([5,6]),
          recently_selected_ids: MapSet.new,
          configuration: %{}
        }
      )
      conn_response = conn
      |> http_basic_authenticate(@username, @password)
      |> put(add_seens_path(user.user_id), workflow_id: workflow_id, subject_ids: '5,6,7,4')
      assert response(conn_response, 204) == ""
      assert user.seen_ids == MapSet.new([4,5,6,7])
    end
  end
end
