defmodule Designator.SubjectSetIterators.Sequential do
  @spec apply_to(Enumerable.t) :: Enumerable.t
  def apply_to(enum) do
    Stream.with_index(enum) |> Stream.map(fn {elem,index} -> {index, elem} end)
  end
end
