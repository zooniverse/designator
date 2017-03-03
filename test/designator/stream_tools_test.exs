defmodule Designator.StreamToolsTest do
  use ExUnit.Case
  alias Designator.StreamTools

  setup do
    Designator.Random.seed({123, 123534, 345345})
    :ok
  end

  test "finite inputs" do
    stream1 = [1,1,1,1,1,1,1,1,1,1]
    stream2 = [2,2,2,2,2,2,2,2,2,2]
    result  = StreamTools.interleave([stream1, stream2]) |> Enum.take(15)
    assert result == [2, 2, 2, 2, 2, 2, 2, 2, 1, 1, 2, 1, 1, 1, 1]
  end

  test "reading exactly to the end" do
    stream1 = [1,1,1,1,1,1,1,1,1,1]
    stream2 = [2,2,2,2,2,2,2,2,2,2]
    result  = StreamTools.interleave([stream1, stream2]) |> Enum.take(20)
    assert result == [2, 2, 2, 2, 2, 2, 2, 2, 1, 1, 2, 1, 1, 1, 1, 1, 2, 1, 1, 1]
  end

  test "reading past the end" do
    stream1 = [1,1,1,1,1,1,1,1,1,1]
    stream2 = [2,2,2,2,2,2,2,2,2,2]
    result  = StreamTools.interleave([stream1, stream2]) |> Enum.take(100)
    assert result == [2, 2, 2, 2, 2, 2, 2, 2, 1, 1, 2, 1, 1, 1, 1, 1, 2, 1, 1, 1]
  end

  test "infinite inputs" do
    stream1 = Stream.repeatedly(fn -> 1 end)
    stream2 = Stream.repeatedly(fn -> 2 end)
    result  = StreamTools.interleave([stream1, stream2]) |> Enum.take(20)
    assert result == [2, 2, 2, 2, 2, 2, 2, 2, 1, 1, 2, 1, 1, 1, 1, 1, 2, 2, 1, 1]
  end

  test "nested streams" do
    stream1 = Stream.repeatedly(fn -> 1 end)
    stream2 = Stream.repeatedly(fn -> 2 end)
    stream3 = StreamTools.interleave([stream1, stream2])
    stream4 = Stream.repeatedly(fn -> 4 end)
    result  = StreamTools.interleave([stream3, stream4]) |> Enum.take(20)
    assert result == [4, 4, 4, 4, 4, 4, 4, 4, 1, 4, 1, 1, 2, 4, 1, 2, 2, 2, 1, 2]
  end

  test "streams with chance" do
    stream1 = %{stream: [1,1,1], chance: 1000}
    stream2 = %{stream: Stream.repeatedly(fn -> 2 end), chance: 1}
    result  = StreamTools.interleave([stream1, stream2]) |> Enum.take(6)
    assert result == [1,1,1,2,2,2]
  end

  @tag timeout: 3000
  test "streams with equal chance should have even distribution" do
    stream1 = %{stream: Stream.repeatedly(fn -> 1 end), chance: 50}
    stream2 = %{stream: Stream.repeatedly(fn -> 2 end), chance: 50}
    result  = StreamTools.interleave([stream1, stream2]) |> Enum.take(1_000_000)

    number_of_ones = Enum.count(result, &(&1 == 1))
    number_of_twos = Enum.count(result, &(&1 == 2))
    assert abs(number_of_twos - number_of_ones) < 1000
  end
end
