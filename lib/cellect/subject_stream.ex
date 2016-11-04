defmodule Cellect.SubjectStream do
  defstruct [:subject_set_id, :stream, :amount, :chance]

  def build({subject_set_id, subject_ids}, configuration \\ %{}), do: build(subject_set_id, subject_ids, configuration)

  def build(subject_set_id, subject_ids, configuration) do
    amount = get_amount(subject_ids)
    %Cellect.SubjectStream{subject_set_id: subject_set_id, stream: build_stream(subject_ids), amount: amount, chance: amount * get_weight(subject_set_id, configuration)}
  end

  ###

  defp build_stream(subject_ids) do
    Stream.repeatedly fn ->
      { _, element} = Cellect.Random.element(subject_ids)
      element
    end
  end

  def get_amount(%Array{} = subject_ids) do
    Array.amount(subject_ids)
  end

  def get_amount(subject_ids) do
    Enum.count(subject_ids)
  end

  def get_weight(subject_set_id, configuration) do
    configuration[to_string(subject_set_id)] || 1
  end
end
