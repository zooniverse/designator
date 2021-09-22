defmodule Designator.SubjectSetIterators.Random do
  alias Designator.Random

  @spec apply_to(Enumerable.t) :: Enumerable.t
  def apply_to(enum) do
    Stream.unfold({enum, MapSet.new}, fn {enum, drawn} ->
      if size(enum) <= MapSet.size(drawn) do
        nil
      else
        {index, element} = Random.unique_element(enum, drawn)

        {{index, element}, {enum, MapSet.put(drawn, index)}}
      end
    end)
  end

  defp size(enum = %array{}) do
    Arrays.size(enum)
  end

  defp size(enum) do
    Enum.count(enum)
  end
end
