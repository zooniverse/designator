defmodule Designator.Migrations.DefaultTablesForTesting do
  use Ecto.Migration

  def change do
    create table(:workflows) do
      add :display_name, :string
      add :project_id, :integer
      add :grouped, :boolean, null: false, default: false
      add :prioritized, :boolean, null: false, default: false
      add :pairwise, :boolean, null: false, default: false
      add :classifications_count, :integer, null: false, default: 0
      add :configuration, :map
      timestamps inserted_at: :created_at
    end

    create table(:subject_sets) do
      add :display_name, :string
      add :project_id, :integer
      add :set_member_subjects_count, :integer, null: false, default: 0
      timestamps inserted_at: :created_at
    end

    create table(:subject_sets_workflows) do
      add :workflow_id, :integer
      add :subject_set_id, :integer
    end

    create table(:set_member_subjects) do
      add :subject_set_id, :integer
      add :subject_id, :integer
      add :priority, :decimal
      add :random, :decimal, null: false
      timestamps inserted_at: :created_at
    end

    create table(:user_project_preferences) do
      add :user_id, :integer
      add :project_id, :integer
      add :settings, :map
      timestamps inserted_at: :created_at
    end

    create table(:user_seen_subjects) do
      add :user_id, :integer
      add :workflow_id, :integer
      add :subject_ids, {:array, :integer}
      timestamps inserted_at: :created_at
    end

    create table(:subject_workflow_counts) do
      add :set_member_subject_id, :integer
      add :workflow_id, :integer
      add :subject_id, :integer
      add :classifications_count, :integer, null: false, default: 0
      add :retired_at, :timestamp
    end
  end
end
