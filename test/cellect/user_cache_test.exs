defmodule Cellect.UserCacheTest do
  use Cellect.ConnCase
  use ExUnit.Case, async: true

  alias Cellect.UserSeenSubject
  alias Cellect.UserCache

  test "loads user seen ids on startup" do
    UserSeenSubject.changeset(%UserSeenSubject{}, %{workflow_id: 1, user_id: 2, subject_ids: [1,2,3,4]}) |> Repo.insert!

    pid = UserCache.start_link({1, 2})

    assert UserCache.get({1, 2}).seen_ids == MapSet.new([1,2,3,4])
  end
end
