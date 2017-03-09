defmodule Designator.SelectionTest do
  use Designator.ConnCase
  use Designator.CacheCase
  alias Designator.Selection
  alias Designator.Repo
  alias Designator.UserSeenSubject
  alias Designator.SubjectSetCache

  test "gold standard weighting" do
    Designator.Random.seed({123, 123534, 345345})
    Designator.WorkflowCache.set(338, %{configuration: %{gold_standard_sets: [681, 1706]},
                                     subject_set_ids: [681, 1706, 1682, 1681]})
    SubjectSetCache.set({338, 681},  %SubjectSetCache{workflow_id: 338, subject_set_id: 681, subject_ids: Array.from_list([1])})
    SubjectSetCache.set({338, 1706}, %SubjectSetCache{workflow_id: 338, subject_set_id: 1706, subject_ids: Array.from_list([2])})
    SubjectSetCache.set({338, 1682}, %SubjectSetCache{workflow_id: 338, subject_set_id: 1682, subject_ids: Array.from_list([3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3])})
    SubjectSetCache.set({338, 1681}, %SubjectSetCache{workflow_id: 338, subject_set_id: 1681, subject_ids: Array.from_list([4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4])})

    assert Selection.select("weighted", 338, 1, 4) == [4, 3, 1, 2]
  end

  test "weighed selection for normal sets" do
    Designator.Random.seed({123, 100020, 345345})
    Designator.WorkflowCache.set(338, %{configuration: %{subject_set_weights: %{"1000" => 900,
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
    Designator.Random.seed({123, 123534, 345345})
    Designator.WorkflowCache.set(338, %{configuration: %{gold_standard_sets: [681, 1706]},
                                     subject_set_ids: [681, 1706, 1682, 1681]})
    SubjectSetCache.set({338, 681},  %SubjectSetCache{workflow_id: 338, subject_set_id: 1000, subject_ids: Array.from_list([1])})
    SubjectSetCache.set({338, 1706}, %SubjectSetCache{workflow_id: 338, subject_set_id: 1001, subject_ids: Array.from_list([2])})
    SubjectSetCache.set({338, 1682}, %SubjectSetCache{workflow_id: 338, subject_set_id: 1002, subject_ids: Array.from_list([3])})
    SubjectSetCache.set({338, 1681}, %SubjectSetCache{workflow_id: 338, subject_set_id: 1003, subject_ids: Array.from_list([4])})
    Designator.UserSeenSubject.changeset(%UserSeenSubject{}, %{user_id: 1, workflow_id: 338, subject_ids: [1,2,3,4]}) |> Repo.insert!

    assert Designator.UserCache.get({338, 1}).seen_ids == MapSet.new([1,2,3,4])

    assert Selection.select("weighted", 338, 1, 4) == []
  end

  test "does not select recently handed out subject ids" do
    Designator.Random.seed({123, 123534, 345345})
    Designator.WorkflowCache.set(338, %{configuration: %{gold_standard_sets: [681, 1706]},
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
    Designator.Random.seed({123, 123534, 345345})
    Designator.WorkflowCache.set(338, %{configuration: %{gold_standard_sets: [681, 1706]},
                                     subject_set_ids: [681, 1706, 1682, 1681]})
    SubjectSetCache.set({338, 681}, %SubjectSetCache{workflow_id: 338, subject_set_id: 1000, subject_ids: Array.from_list([])})
    SubjectSetCache.set({338, 1706},%SubjectSetCache{workflow_id: 338, subject_set_id: 1001, subject_ids: Array.from_list([])})
    SubjectSetCache.set({338, 1682},%SubjectSetCache{workflow_id: 338, subject_set_id: 1002, subject_ids: Array.from_list([3])})
    SubjectSetCache.set({338, 1681},%SubjectSetCache{workflow_id: 338, subject_set_id: 1003, subject_ids: Array.from_list([4])})

    assert Selection.select("weighted", 338, 1, 2) == [4, 3]
  end
end
