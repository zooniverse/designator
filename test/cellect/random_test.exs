defmodule Cellect.RandomTest do
  use ExUnit.Case
  alias Cellect.Random

  setup do
    Random.seed({123, 123534, 345345})
    :ok
  end

  test "get a random element" do
    assert Random.element([:a, :b, :c, :d, :e]) == {0, :a}
    assert Random.element([:a, :b, :c, :d, :e]) == {4, :e}
  end

  test "get a random element with weights" do
    assert Random.weighted([{:a, 0}, {:b, 1}]) == {1, {:b, 1}}

    data = [{:a, 0.5}, {:b, 0.1}, {:c, 0.1}, {:d, 0.1}, {:e, 0.1}, {:f, 0.1}]
    indexes = Stream.repeatedly(fn -> Random.weighted(data) end)
              |> Stream.map(&elem(&1, 0))
              |> Enum.take(16)

    assert indexes == [2, 5, 3, 1, 4, 4, 5, 0, 0, 5, 0, 0, 0, 0, 0, 4]
  end
end
