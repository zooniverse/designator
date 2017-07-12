defmodule Designator.UserTest do
  use Designator.ConnCase

  describe "configuration" do
    test "returns the per-workflow user configuration" do
      Ecto.Adapters.SQL.query!(Designator.Repo, "INSERT INTO workflows (id, project_id, created_at, updated_at) VALUES (1, 2, NOW(), NOW())")
      Ecto.Adapters.SQL.query!(Designator.Repo, "INSERT INTO user_project_preferences (user_id, project_id, preferences, created_at, updated_at) VALUES (3, 2, '{\"designator\": {\"1\": {\"subject_set_chances\": {}}}}'::jsonb, NOW(), NOW())")

      assert Designator.User.configuration(1, 3) == %{"subject_set_chances" => %{}}
    end

    test "when no user_project_preference exists" do
      Ecto.Adapters.SQL.query!(Designator.Repo, "INSERT INTO workflows (id, project_id, created_at, updated_at) VALUES (1, 2, NOW(), NOW())")

      assert Designator.User.configuration(1, 3) == %{}
    end

    test "when user_project_preference is not configured for designator" do
      Ecto.Adapters.SQL.query!(Designator.Repo, "INSERT INTO workflows (id, project_id, created_at, updated_at) VALUES (1, 2, NOW(), NOW())")
      Ecto.Adapters.SQL.query!(Designator.Repo, "INSERT INTO user_project_preferences (user_id, project_id, preferences, created_at, updated_at) VALUES (3, 2, '{\"asdf\": 1}'::jsonb, NOW(), NOW())")

      assert Designator.User.configuration(1, 3) == %{}
    end

    test "when user_project_preference does not have designator configuration for this workflow" do
      Ecto.Adapters.SQL.query!(Designator.Repo, "INSERT INTO workflows (id, project_id, created_at, updated_at) VALUES (1, 2, NOW(), NOW())")
      Ecto.Adapters.SQL.query!(Designator.Repo, "INSERT INTO user_project_preferences (user_id, project_id, preferences, created_at, updated_at) VALUES (3, 2, '{\"designator\": {\"9000\": {\"subject_set_chances\": {}}}}'::jsonb, NOW(), NOW())")

      assert Designator.User.configuration(1, 3) == %{}
    end
  end
end
