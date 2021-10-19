defmodule Designator.SubjectStream do
  defstruct [:subject_set_id, :stream, :amount, :chance]

  def build(%{subject_set_id: subject_set_id, subject_ids: subject_ids}, subject_set_iterator) do
    amount = get_amount(subject_ids)
    %Designator.SubjectStream{subject_set_id: subject_set_id, stream: build_stream(subject_ids, subject_set_iterator), amount: amount, chance: amount}
  end

  ###

  defp build_stream(subject_ids, subject_set_iterator) do
    subject_set_iterator.apply_to(subject_ids) |> Stream.map(fn {_idx, elm} -> elm end)
  end

  # %_array_struct{contents: _array} is the struct sig of both array implementation types
  # see arrays package for details on the types
  def get_amount(%_array_struct{contents: _array} = subject_ids) do
    Arrays.size(subject_ids)
  end

  def get_amount(subject_ids) do
    Enum.count(subject_ids)
  end
end
