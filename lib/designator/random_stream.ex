defmodule Designator.RandomStream do
  alias Designator.Random

  @spec shuffle(Enumerable.t) :: Enumerable.t
  def shuffle(enum) do
    Stream.unfold({enum, MapSet.new}, fn {enum, drawn} ->
      if size(enum) <= MapSet.size(drawn) do
        nil
      else
        {index, element} = Random.unique_element(enum, drawn)

        {{index, element}, {enum, MapSet.put(drawn, index)}}
      end
    end)
  end

  defp size(enum = %Array{}) do
    Array.size(enum)
  end

  defp size(enum) do
    Enum.count(enum)
  end
end
