defmodule Cellect.StreamToolsTest do
  use ExUnit.Case
  alias Cellect.StreamTools

  setup do
    :random.seed(1)
    :ok
  end

  test "interleave" do
    # stream1 = Stream.repeatedly(fn -> 1 end)
    # stream2 = Stream.repeatedly(fn -> 2 end)
    stream1 = [1,1,1]
    stream2 = [2,2,2]
    result  = StreamTools.interleave([stream1, stream2]) |> Enum.take(6)
    assert result == [1,2,1,1,2,2]
  end
end
