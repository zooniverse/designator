defmodule Cellect.StreamToolsTest do
  use ExUnit.Case
  alias Cellect.StreamTools

  setup do
    Cellect.Random.seed({123, 123534, 345345})
    :ok
  end

  test "finite inputs" do
    stream1 = [1,1,1]
    stream2 = [2,2,2]
    result  = StreamTools.interleave([stream1, stream2]) |> Enum.take(4)
    assert result == [2,2,1,1]
  end

  test "reading exactly to the end" do
    stream1 = [1,1,1]
    stream2 = [2,2,2]
    result  = StreamTools.interleave([stream1, stream2]) |> Enum.take(6)
    assert result == [2,2,1,1,2,1]
  end

  test "reading past the end" do
    stream1 = [1,1,1]
    stream2 = [2,2,2]
    result  = StreamTools.interleave([stream1, stream2]) |> Enum.take(10)
    assert result == [2,2,1,1,2,1]
  end

  test "infinite inputs" do
    stream1 = Stream.repeatedly(fn -> 1 end)
    stream2 = Stream.repeatedly(fn -> 2 end)
    result  = StreamTools.interleave([stream1, stream2]) |> Enum.take(6)
    assert result == [2,2,1,1,2,2]
  end

  test "nested streams" do
    stream1 = Stream.repeatedly(fn -> 1 end)
    stream2 = Stream.repeatedly(fn -> 2 end)
    stream3 = StreamTools.interleave([stream1, stream2])
    stream4 = Stream.repeatedly(fn -> 4 end)
    result  = StreamTools.interleave([stream3, stream4]) |> Enum.take(10)
    assert result == [4, 4, 1, 4, 4, 4, 4, 2, 4, 2]
  end
end
