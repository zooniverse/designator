defmodule Cellect.WorkflowTest do
  use Cellect.ConnCase

  describe "subject_set_ids" do
    test "returns linked subject set ids" do
      Ecto.Adapters.SQL.query!(Cellect.Repo, "INSERT INTO workflows (id, created_at, updated_at) VALUES (1, NOW(), NOW())")
      Ecto.Adapters.SQL.query!(Cellect.Repo, "INSERT INTO subject_sets_workflows (workflow_id, subject_set_id) VALUES (1, 1), (1, 2), (1, 3)")

      assert Cellect.Workflow.subject_set_ids(1) |> Enum.sort == [1,2,3]
    end
  end

  describe "subject_ids" do
    test "returns subject ids" do
      Ecto.Adapters.SQL.query!(Cellect.Repo, "INSERT INTO workflows (id, created_at, updated_at) VALUES (1, NOW(), NOW())")
      Ecto.Adapters.SQL.query!(Cellect.Repo, "INSERT INTO subject_sets_workflows (workflow_id, subject_set_id) VALUES (1, 1)")
      Ecto.Adapters.SQL.query!(Cellect.Repo, "INSERT INTO set_member_subjects (subject_set_id, subject_id, random, created_at, updated_at) VALUES
        (1, 1, 0.5, NOW(), NOW()),
        (1, 2, 0.5, NOW(), NOW()),
        (1, 3, 0.5, NOW(), NOW())")

      assert Cellect.Workflow.subject_ids(1, 1) |> Enum.sort == [1,2,3]
    end

    test "does not return retired subjects" do
      Ecto.Adapters.SQL.query!(Cellect.Repo, "INSERT INTO workflows (id, created_at, updated_at) VALUES (1, NOW(), NOW())")
      Ecto.Adapters.SQL.query!(Cellect.Repo, "INSERT INTO subject_sets_workflows (workflow_id, subject_set_id) VALUES (1, 1)")
      Ecto.Adapters.SQL.query!(Cellect.Repo, "INSERT INTO set_member_subjects (subject_set_id, subject_id, random, created_at, updated_at) VALUES
      (1, 1, 0.5, NOW(), NOW()),
      (1, 2, 0.5, NOW(), NOW()),
      (1, 3, 0.5, NOW(), NOW())")
      Ecto.Adapters.SQL.query!(Cellect.Repo, "INSERT INTO subject_workflow_counts (workflow_id, subject_id, retired_at) VALUES
      (1, 1, NOW())")

      assert Cellect.Workflow.subject_ids(1, 1) |> Enum.sort == [2,3]
    end

    test "does not return subjects when they have been classified on another workflow" do
      Ecto.Adapters.SQL.query!(Cellect.Repo, "INSERT INTO workflows (id, created_at, updated_at) VALUES
      (1, NOW(), NOW()),
      (2, NOW(), NOW())")
      Ecto.Adapters.SQL.query!(Cellect.Repo, "INSERT INTO subject_sets_workflows (workflow_id, subject_set_id) VALUES (1, 1)")
      Ecto.Adapters.SQL.query!(Cellect.Repo, "INSERT INTO set_member_subjects (subject_set_id, subject_id, random, created_at, updated_at) VALUES
      (1, 1, 0.5, NOW(), NOW()),
      (1, 2, 0.5, NOW(), NOW()),
      (1, 3, 0.5, NOW(), NOW())")
      Ecto.Adapters.SQL.query!(Cellect.Repo, "INSERT INTO subject_workflow_counts (workflow_id, subject_id, retired_at) VALUES
      (1, 1, NULL),
      (2, 1, NULL)")

      assert Cellect.Workflow.subject_ids(1, 1) |> Enum.sort == [1,2,3]
    end
  end
end
