defmodule Designator.SubjectSetIterators.SequentialTest do
  use ExUnit.Case

  import Designator.SubjectSetIterators.Sequential

  test "empty enum returns nothing" do
    assert ([] |> apply_to |> Stream.take(5) |> Enum.into([])) == []
  end

  test "returns data" do
    assert (1..5 |> apply_to |> Stream.take(5)) |> Enum.into([]) == [{0, 1}, {1, 2}, {2, 3}, {3, 4}, {4, 5}]
  end
end
