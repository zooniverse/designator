# Reader beware: you might not need to fully understand this file. This code is
# optimized for execution rather than comprehension.
# 
# See docs/streamtools.md for a guide on how this works. Most of the execution
# happens in do_interleave, which has step-by-step comments as well.
defmodule Designator.StreamTools do
  def interleave(streams) do
    step = fn x, acc -> { :suspend, [x | acc] } end

    subject_set_streams = Enum.map streams, fn stream ->
      case stream do
        %{stream: stream, chance: chance} ->
          %{ fun: &Enumerable.reduce(stream, &1, step), acc: [], chance: chance }
        stream ->
          %{ fun: &Enumerable.reduce(stream, &1, step), acc: [], chance: 1 }
      end
    end

    &do_interleave(subject_set_streams, &1, &2)
  end

  defp do_interleave(subject_set_streams, {:halt, acc}, _emitter) do
    do_interleave_close(subject_set_streams)
    {:halted, acc}
  end

  defp do_interleave(subject_set_streams, {:suspend, acc}, emitter) do
    {:suspended, acc, &do_interleave(subject_set_streams, &1, emitter)}
  end

  defp do_interleave([], {:cont, acc}, _emitter) do
    {:done, acc}
  end

  defp do_interleave(subject_set_streams, {:cont, acc}, emitter) do
    # First, use the chances to pick a random SubjectSetStream
    {idx, {subject_set_stream, _chance}} = Designator.Random.weighted(Enum.map(subject_set_streams, fn interleave -> {interleave, interleave.chance} end))

    # Then call that stream's continuation function to get a random subject from it
    case subject_set_stream[:fun].({ :cont, subject_set_stream[:acc] }) do
      # :suspended means we got a subject, and the updated state representation of that stream
      { :suspended, [subject | next_fun_acc], next_fun } ->
        # Since we got a subject, call our emitter function to emit it to whatever is actually reading data
        next_acc = emitter.(subject, acc)

        # Then we need to put the new state representation into the list of subject_set_streams so that next
        # time we hit this subject set, it knows that this particular subject was already selected and
        # is not emitted again.
        next_subject_set_stream = Map.merge(subject_set_stream, %{fun: next_fun, acc: next_fun_acc})
        next_subject_set_streams = List.replace_at(subject_set_streams, idx, next_subject_set_stream)

        # And since we emitted, we recurse to keep emitting more, with the new list of subject_set_streams of course
        do_interleave(next_subject_set_streams, next_acc, emitter)

      # :done means that this subject set has already emitted all of the subjects it has, and there is no
      # more data to read from it
      { :done, _next_fun_acc } ->
        # We didn't get a subject that we can emit ourselves, so we don't call our emitter function.

        # Knowing that this subject set is depleted, we might as well remove it from the list of subject_set_streams
        next_subject_set_streams = List.delete_at(subject_set_streams, idx)

        # And again, recurse to keep emitting. It doesn't matter that we didn't emit anything, whatever
        # is reading from us should track how many were emitted and stop once enough have been emitted.
        do_interleave(next_subject_set_streams, {:cont, acc}, emitter)

      # This is a possible thing that could be received from it, so for completeness we handle it.
      # It should never happen in practice, and if it does the `throw` here will report it to Rollbar.
      { :halted, _next_fun_acc } ->
        IO.inspect "Not sure what to do here yet, needs test case"
        throw :unimplemented
    end
  end

  def do_interleave_close([]) do
    :ok
  end

  def do_interleave_close([%{fun: fun, acc: acc} | subject_set_streams]) do
    fun.({:halt, acc})
    do_interleave_close(subject_set_streams)
  end
end
