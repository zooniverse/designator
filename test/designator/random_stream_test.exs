defmodule Designator.RandomStreamTest do
  use ExUnit.Case

  import Designator.RandomStream

  test "empty enum returns nothing" do
    assert (1..5 |> shuffle |> Stream.take(5) |> Enum.sort) == [{0, 1}, {1, 2}, {2, 3}, {3, 4}, {4, 5}]
  end
end
