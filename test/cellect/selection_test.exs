defmodule Cellect.SelectionTest do
  use Cellect.ConnCase
  alias Cellect.Selection
  alias Cellect.Repo
  alias Cellect.Workflow

  test "gold chance" do
    assert Selection.gold_chance(0) == 0.4
    assert Selection.gold_chance(1) == 0.4
    assert Selection.gold_chance(19) == 0.4
    assert Selection.gold_chance(20) == 0.4

    assert Selection.gold_chance(21) == 0.3
    assert Selection.gold_chance(39) == 0.3
    assert Selection.gold_chance(40) == 0.3

    assert Selection.gold_chance(41) == 0.2
    assert Selection.gold_chance(59) == 0.2
    assert Selection.gold_chance(60) == 0.2

    assert Selection.gold_chance(61) == 0.1
    assert Selection.gold_chance(70) == 0.1
    assert Selection.gold_chance(1200) == 0.1
  end

  test "weighed selection" do
    Cellect.Random.seed({123, 123534, 345345})
    Cellect.Workflow.changeset(%Workflow{}, %{id: 338, configuration: %{gold_standard_sets: [681, 1706]}}) |> Repo.insert!
    Cellect.Cache.SubjectIds.set([{681, [1]}, {1706, [2]}, {1682, [3]}, {1681, [4]}])

    assert Selection.select("weighted", 338, 1, 4) == [4, 2, 1, 3]
  end
end
