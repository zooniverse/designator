defmodule Designator.UserControllerTest do
  use Designator.ConnCase

  @username Application.fetch_env!(:designator, :api_auth)[:username]
  @password Application.fetch_env!(:designator, :api_auth)[:password]

  setup %{conn: conn} do
    workflow_id = 2
    user_id = 1
    user_cache_key = { workflow_id, user_id }
    # initialize / reset the user cache data
    # couldn't get the cache store to reset as per
    # https://github.com/sasa1977/con_cache#testing-in-your-application
    Designator.UserCache.set(
      user_cache_key,
      %{
        seen_ids: MapSet.new([]),
        recently_selected_ids: MapSet.new,
        configuration: %{}
      }
    )
    user = Designator.UserCache.get(user_cache_key)
    {
      :ok,
      [
        user: user,
        workflow_id: 2,
        conn: put_req_header(conn, "accept", "application/json")
      ]
    }
  end

  def add_seens_path(user_id) do
    "/api/users/#{user_id}/add_seen_subjects"
  end

  def put_req(conn, user_id, workflow_id, subject_ids) do
    params = Poison.encode!(%{workflow_id: workflow_id, subject_ids: subject_ids})
    conn
    |> put_req_header("content-type", "application/json")
    |> http_basic_authenticate(@username, @password)
    |> put(add_seens_path(user_id), params)
  end

  def http_basic_authenticate(conn, username, password) do
    put_req_header(conn, "authorization", "Basic " <> Base.encode64(username <> ":" <> password))
  end

  describe "adding a known user seen subjects for a workflow" do
    test "requires authentication", %{user: user, workflow_id: workflow_id, conn: conn} do
      conn_response = conn
      |> put(add_seens_path(user.user_id), workflow_id: workflow_id, subject_ids: [1])
      assert response(conn_response, 401) == "401 Unauthorized"
    end

    test "respons with a 201 created response code for an not loaded users", %{workflow_id: workflow_id, conn: conn} do
      conn_response = put_req(conn, "99", workflow_id, [1])
      assert response(conn_response, 201) == ""
    end

    test "respons with a 204 no-content response code for loaded users", %{user: user, workflow_id: workflow_id, conn: conn} do
      Designator.UserCache.set(
        { workflow_id, user.user_id },
        %{seen_ids: MapSet.new([9])}
      )
      conn_response = put_req(conn, user.user_id, workflow_id, [1])
      assert response(conn_response, 204) == ""
    end

    test "adds the subject ids", %{user: user, workflow_id: workflow_id, conn: conn} do
      conn_response = put_req(conn, user.user_id, workflow_id, [3,2,1])
      assert response(conn_response, 204) == ""
      user = Designator.UserCache.get({workflow_id, user.user_id})
      assert user.seen_ids == MapSet.new([3,2,1])
    end

    test "adds the subject id when using the subject_id param", %{user: user, workflow_id: workflow_id, conn: conn} do
      conn_response = conn
      |> http_basic_authenticate(@username, @password)
      |> put("/api/users/#{user.user_id}/add_seen_subject", workflow_id: workflow_id, subject_id: 1432)
      assert response(conn_response, 204) == ""
      user = Designator.UserCache.get({workflow_id, user.user_id})
      assert user.seen_ids == MapSet.new([1432])
    end

    test "rejects non integer subject ids in list", %{user: user, workflow_id: workflow_id, conn: conn} do
      conn_response = put_req(conn, user.user_id, workflow_id, [1, "test", 2])
      four_twenty_two = json_response(conn_response, 422)
      assert four_twenty_two["errors"] == "invalid subject id supplied, must be a valid integer"
    end

    test "rejects non integer subject id", %{user: user, workflow_id: workflow_id, conn: conn} do
      conn_response = conn
      |> http_basic_authenticate(@username, @password)
      |> put(add_seens_path(user.user_id), workflow_id: workflow_id, subject_id: "test")
      four_twenty_two = json_response(conn_response, 422)
      assert four_twenty_two["errors"] == "invalid subject id supplied, must be a valid integer"
    end

    test "casts the subject_ids to ints before storing", %{user: user, workflow_id: workflow_id, conn: conn} do
      conn_response = put_req(conn, user.user_id, workflow_id, [3,"2",1])
      assert response(conn_response, 204) == ""
      user = Designator.UserCache.get({workflow_id, user.user_id})
      assert user.seen_ids == MapSet.new([3,2,1])
    end

    test "does de-duplicate the incoming subject ids", %{user: user, workflow_id: workflow_id, conn: conn} do
      Designator.UserCache.set(
        { workflow_id, user.user_id },
        %{
          seen_ids: MapSet.new([5,6]),
          recently_selected_ids: MapSet.new,
          configuration: %{}
        }
      )
      conn_response = put_req(conn, user.user_id, workflow_id, [5,6,7,4])
      assert response(conn_response, 204) == ""
      user = Designator.UserCache.get({workflow_id, user.user_id})
      assert user.seen_ids == MapSet.new([4,5,6,7])
    end
  end
end
