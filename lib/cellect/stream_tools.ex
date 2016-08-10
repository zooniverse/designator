defmodule Cellect.StreamTools do


  def interleave(streams) do
    step = fn x, acc -> { :suspend, [x | acc] } end
    interleaves = Enum.map streams, fn stream ->
      &Enumerable.reduce(stream, &1, step)
    end

    do_interleave(interleaves, []) |> :lists.reverse()
  end

  defp do_interleave([], acc) do
    acc
  end

  defp do_interleave(interleaves, acc) do
    {idx, r} = pick_random(interleaves)

    case r.({ :cont, acc }) do
      { :suspended, acc, next_r } ->
        next_interleaves = List.replace_at(interleaves, idx, next_r)
        do_interleave(next_interleaves, acc)
      { :halted, acc } ->
        acc
      { :done, acc } ->
        next_interleaves = List.delete_at(interleaves, idx)
        do_interleave(next_interleaves, acc)
    end
  end

  defp finish_interleave(a_or_b, acc) do
    case a_or_b.({ :cont, acc }) do
      { :suspended, acc, a_or_b } ->
        finish_interleave(a_or_b, acc)
      { _, acc } ->
        acc
    end
  end

  defp pick_random(enumerable) do
    size = Enum.count(enumerable)
    index = :random.uniform(size) - 1
    element = Enum.at(enumerable, index)

    { index, element }
  end







  # def merge(streams) do
  #   step   = &do_merge_step(&1, &2)
  #   merges = Enum.map streams, fn stream ->
  #     { &Enumerable.reduce(stream, &1, step), [] }
  #   end

  #   # Return a function as a lazy enumerator.
  #   &do_merge(merges, &1, &2)
  # end

  # defp do_merge(merges, {:halt, acc}, _fun) do
  #   do_merge_close(merges)
  #   {:halted, acc}
  # end

  # defp do_merge(merges, {:suspend, acc}, fun) do
  #   {:suspended, acc, &do_merge(merges, &1, fun)}
  # end

  # defp do_merge(merges, {:cont, acc}, callback) do
  #   try do
  #     do_merge(merges, acc, callback, [], [])
  #   catch
  #     kind, reason ->
  #       stacktrace = System.stacktrace
  #       do_merge_close(merges)
  #       :erlang.raise(kind, reason, stacktrace)
  #   else
  #     {:next, buffer, acc} ->
  #       do_merge(buffer, acc, callback)
  #     {:done, _} = o ->
  #       o
  #   end
  # end

  # defp do_merge([{fun, fun_acc} | t], acc, callback, list, buffer) do
  #   case fun.({:cont, fun_acc}) do
  #     {:suspended, [i | fun_acc], fun} ->
  #       do_merge(t, acc, callback, [i | list], [{fun, fun_acc} | buffer])
  #     {_, _} ->
  #       do_merge_close(:lists.reverse(buffer, t))
  #       {:done, acc}
  #   end
  # end

  # defp do_merge([], acc, callback, list, buffer) do
  #   IO.inspect list
  #   merged = List.to_tuple(:lists.reverse(list))
  #   {:next, :lists.reverse(buffer), callback.(merged, acc)}
  # end

  # defp do_merge_close([]), do: :ok
  # defp do_merge_close([{fun, acc} | t]) do
  #   fun.({:halt, acc})
  #   do_merge_close(t)
  # end

  # defp do_merge_step(x, acc) do
  #   {:suspend, [x | acc]}
  # end














  # def interleave(streams) do
  #   # step = fn x, acc -> { :suspend, [x | acc] } end

  #   # reducers = Enum.map streams, fn stream ->
  #   #   &Enumerable.reduce(stream, &1, step)
  #   # end

  #   # &do_interleave(reducers, [])

  #   # Stream.resource(
  #   #   fn -> streams end
  #   #   fn streams ->
  #   #     stream = Enum.random(streams)
  #   #     {[Enum.take]}
  #   # )
  # end

  # def do_interleave(reducers, acc) do
  #   reducer = Enum.random(reducers)

  #   case reducer.({:cont, acc}) do
  #     {:suspended, acc, reducer} ->
  #       IO.inspect(acc)
  #       do_interleave(reducers, acc)
  #     {:halted, acc} ->
  #       IO.inspect(acc)
  #       acc
  #     {:done, acc} ->
  #       IO.inspect(acc)
  #       acc
  #   end
  # end
end
