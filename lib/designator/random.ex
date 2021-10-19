defmodule Designator.Random do
  def seed(seed) do
    :rand.seed(:exs1024, seed)
  end

  # %_array_struct{contents: _array} is the struct sig of both array implementation types
  # see arrays package for details on the types
  def element(%_array_struct{contents: _array} = enumerable) do
    case Arrays.size enumerable do
      0 -> nil
      size ->
        index = :rand.uniform(size) - 1
        element = Arrays.get(enumerable, index)
        {index, element}
    end
  end

  def element(enumerable) do
    size = Enum.count(enumerable)
    index = :rand.uniform(size) - 1
    element = Enum.at(enumerable, index)

    {index, element}
  end

  def unique_element(enumerable, drawn) do
    {index, element} = element(enumerable)

    if MapSet.member?(drawn, index) do
      unique_element(enumerable, drawn)
    else
      {index, element}
    end
  end

  def weighted(enumerable) do
    weights = Enum.map(enumerable, &elem(&1, 1))
    total   = Enum.sum(weights)
    choice  = :rand.uniform() * total

    do_weighted(enumerable, choice, 0)
  end

  def do_weighted([{_, weight} = h | t], choice, index) do
    if weight >= choice do
      {index, h}
    else
      do_weighted(t, choice - weight, index + 1)
    end
  end

  def do_weighted([], _, _) do
    throw :table
  end
end
