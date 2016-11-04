defmodule Cellect.StreamTools do
  def interleave(streams) do
    step = fn x, acc -> { :suspend, [x | acc] } end

    interleaves = Enum.map streams, fn stream ->
      case stream do
        %{stream: stream, chance: chance} ->
          %{ fun: &Enumerable.reduce(stream, &1, step), acc: [], chance: chance }
        stream ->
          %{ fun: &Enumerable.reduce(stream, &1, step), acc: [], chance: 1 }
      end
    end

    &do_interleave(interleaves, &1, &2)
  end

  defp do_interleave(interleaves, {:halt, acc}, _callback) do
    do_interleave_close(interleaves)
    {:halted, acc}
  end

  defp do_interleave(interleaves, {:suspend, acc}, callback) do
    {:suspended, acc, &do_interleave(interleaves, &1, callback)}
  end

  defp do_interleave([], {:cont, acc}, _callback) do
    {:done, acc}
  end

  defp do_interleave(interleaves, {:cont, acc}, callback) do
    {idx, {elm, chance}} = Cellect.Random.weighted(Enum.map(interleaves, fn interleave -> {interleave, interleave.chance} end))

    case elm[:fun].({ :cont, elm[:acc] }) do
      { :suspended, [i | next_fun_acc], next_fun } ->
        next_acc = callback.(i, acc)
        next_elm = Map.merge(elm, %{fun: next_fun, acc: next_fun_acc})
        next_interleaves = List.replace_at(interleaves, idx, next_elm)

        do_interleave(next_interleaves, next_acc, callback)
      { :halted, _next_fun_acc } ->
        IO.inspect "Not sure what to do here yet, needs test case"
        throw :unimplemented
      { :done, _next_fun_acc } ->
        next_interleaves = List.delete_at(interleaves, idx)
        do_interleave(next_interleaves, {:cont, acc}, callback)
    end
  end

  def do_interleave_close([]) do
    :ok
  end

  def do_interleave_close([%{fun: fun, acc: acc} | interleaves]) do
    fun.({:halt, acc})
    do_interleave_close(interleaves)
  end
end
