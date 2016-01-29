defmodule Cellect.RandomSelection do
  def sample(subject_ids, seen_ids, amount) do
    indices = random_indices_with_seen(subject_ids, seen_ids, amount, HashSet.new)

    Enum.map(indices, fn(idx) -> Array.get(subject_ids, idx) end)
  end

  def random_indices_with_seen(_, _, 0, selection) do
    selection
  end

  def random_indices_with_seen(subject_ids, seen_ids, count, selection) do
    size  = Array.size subject_ids
    index = :random.uniform(size) - 1

    if Set.member?(selection, index) || Set.member?(seen_ids, Array.get(subject_ids, index)) do
      random_indices_with_seen(subject_ids, seen_ids, count,   selection)
    else
      random_indices_with_seen(subject_ids, seen_ids, count-1, Set.put(selection, index))
    end
  end
end
