defmodule Designator.SubjectStream do
  defstruct [:subject_set_id, :stream, :amount, :chance]

  def build(%{subject_set_id: subject_set_id, subject_ids: subject_ids}) do
    amount = get_amount(subject_ids)
    %Designator.SubjectStream{subject_set_id: subject_set_id, stream: build_stream(subject_ids), amount: amount, chance: amount}
  end

  ###

  defp build_stream(subject_ids) do
    Designator.SubjectSetIterators.Randomly.apply_to(subject_ids) |> Stream.map(fn {_idx, elm} -> elm end)
  end

  def get_amount(%Array{} = subject_ids) do
    Array.size(subject_ids)
  end

  def get_amount(subject_ids) do
    Enum.count(subject_ids)
  end
end
