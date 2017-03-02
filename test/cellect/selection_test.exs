defmodule Cellect.SelectionTest do
  use Cellect.ConnCase
  use Cellect.CacheCase
  alias Cellect.Selection
  alias Cellect.Repo
  alias Cellect.UserSeenSubject
  alias Cellect.SubjectSetCache

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

  test "gold standard weighting" do
    Cellect.Random.seed({123, 123534, 345345})
    Cellect.WorkflowCache.set(338, %{configuration: %{gold_standard_sets: [681, 1706]},
                                     subject_set_ids: [681, 1706, 1682, 1681]})
    SubjectSetCache.set({338, 681},  %SubjectSetCache{workflow_id: 338, subject_set_id: 681, subject_ids: Array.from_list([1])})
    SubjectSetCache.set({338, 1706}, %SubjectSetCache{workflow_id: 338, subject_set_id: 1706, subject_ids: Array.from_list([2])})
    SubjectSetCache.set({338, 1682}, %SubjectSetCache{workflow_id: 338, subject_set_id: 1682, subject_ids: Array.from_list([3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3])})
    SubjectSetCache.set({338, 1681}, %SubjectSetCache{workflow_id: 338, subject_set_id: 1681, subject_ids: Array.from_list([4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4])})

    assert Selection.select("weighted", 338, 1, 4) == [4, 3, 1, 2]
  end

  test "weighed selection for normal sets" do
    Cellect.Random.seed({123, 100020, 345345})
    Cellect.WorkflowCache.set(338, %{configuration: %{subject_set_weights: %{"1000" => 900,
                                                                             "1001" => 99,
                                                                             "1002" => 9.9,
                                                                             "1003" => 0.1}},
                                     subject_set_ids: [1000, 1001, 1002, 1003]})
    SubjectSetCache.set({338, 1000}, %SubjectSetCache{workflow_id: 338, subject_set_id: 1000, subject_ids: Array.from_list([1, 2, 3])})
    SubjectSetCache.set({338, 1001}, %SubjectSetCache{workflow_id: 338, subject_set_id: 1001, subject_ids: Array.from_list([4])})
    SubjectSetCache.set({338, 1002}, %SubjectSetCache{workflow_id: 338, subject_set_id: 1002, subject_ids: Array.from_list([5])})
    SubjectSetCache.set({338, 1003}, %SubjectSetCache{workflow_id: 338, subject_set_id: 1003, subject_ids: Array.from_list([6])})

    assert Selection.select("weighted", 338, 1, 6) == [5, 3, 6, 4, 1, 2]
  end

  @tag timeout: 1000
  test "seen all subjects" do
    Cellect.Random.seed({123, 123534, 345345})
    Cellect.WorkflowCache.set(338, %{configuration: %{gold_standard_sets: [681, 1706]},
                                     subject_set_ids: [681, 1706, 1682, 1681]})
    SubjectSetCache.set({338, 681},  %SubjectSetCache{workflow_id: 338, subject_set_id: 1000, subject_ids: Array.from_list([1])})
    SubjectSetCache.set({338, 1706}, %SubjectSetCache{workflow_id: 338, subject_set_id: 1001, subject_ids: Array.from_list([2])})
    SubjectSetCache.set({338, 1682}, %SubjectSetCache{workflow_id: 338, subject_set_id: 1002, subject_ids: Array.from_list([3])})
    SubjectSetCache.set({338, 1681}, %SubjectSetCache{workflow_id: 338, subject_set_id: 1003, subject_ids: Array.from_list([4])})
    Cellect.UserSeenSubject.changeset(%UserSeenSubject{}, %{user_id: 1, workflow_id: 338, subject_ids: [1,2,3,4]}) |> Repo.insert!

    assert Cellect.UserCache.get({338, 1}).seen_ids == MapSet.new([1,2,3,4])

    assert Selection.select("weighted", 338, 1, 4) == []
  end

  test "does not select recently handed out subject ids" do
    Cellect.Random.seed({123, 123534, 345345})
    Cellect.WorkflowCache.set(338, %{configuration: %{gold_standard_sets: [681, 1706]},
                                     subject_set_ids: [681, 1706, 1682, 1681]})
    SubjectSetCache.set({338, 681},  %SubjectSetCache{workflow_id: 338, subject_set_id: 681, subject_ids: Array.from_list([1])})
    SubjectSetCache.set({338, 1706}, %SubjectSetCache{workflow_id: 338, subject_set_id: 1706, subject_ids: Array.from_list([2])})
    SubjectSetCache.set({338, 1682}, %SubjectSetCache{workflow_id: 338, subject_set_id: 1682, subject_ids: Array.from_list([3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3])})
    SubjectSetCache.set({338, 1681}, %SubjectSetCache{workflow_id: 338, subject_set_id: 1681, subject_ids: Array.from_list([4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4])})

    Selection.select("weighted", 338, 1, 4)
    assert Selection.select("weighted", 338, 1, 4) == []
  end


  test "workflow that does not exist" do
    assert Selection.select("uniform", 404, 1, 4) == []
    assert Selection.select("weighted", 404, 1, 4) == []
  end

  test "empty subject set" do
    Cellect.Random.seed({123, 123534, 345345})
    Cellect.WorkflowCache.set(338, %{configuration: %{gold_standard_sets: [681, 1706]},
                                     subject_set_ids: [681, 1706, 1682, 1681]})
    SubjectSetCache.set({338, 681}, %SubjectSetCache{workflow_id: 338, subject_set_id: 1000, subject_ids: Array.from_list([])})
    SubjectSetCache.set({338, 1706},%SubjectSetCache{workflow_id: 338, subject_set_id: 1001, subject_ids: Array.from_list([])})
    SubjectSetCache.set({338, 1682},%SubjectSetCache{workflow_id: 338, subject_set_id: 1002, subject_ids: Array.from_list([3])})
    SubjectSetCache.set({338, 1681},%SubjectSetCache{workflow_id: 338, subject_set_id: 1003, subject_ids: Array.from_list([4])})

    assert Selection.select("weighted", 338, 1, 2) == [4, 3]
  end
end
