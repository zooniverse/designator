defmodule Cellect.SubjectStream do
  defstruct [:subject_set_id, :stream, :size, :chance]

  def build({subject_set_id, subject_ids}), do: build(subject_set_id, subject_ids)

  def build(subject_set_id, subject_ids) do
    size = get_size(subject_ids)
    %Cellect.SubjectStream{subject_set_id: subject_set_id, stream: build_stream(subject_ids), size: size, chance: size}
  end

  ###

  defp build_stream(subject_ids) do
    Stream.repeatedly fn ->
      { _, element} = Cellect.Random.element(subject_ids)
      element
    end
  end

  def get_size(%Array{} = subject_ids) do
    Array.size(subject_ids)
  end

  def get_size(subject_ids) do
    Enum.count(subject_ids)
  end
end
