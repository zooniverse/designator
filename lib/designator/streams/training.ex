defmodule Designator.Streams.Training do
  alias Designator.SubjectStream
  alias Designator.StreamTools

  def apply_weights(streams, workflow, user) do
    seen_subject_ids = user.seen_ids
    training_set_ids = workflow.configuration["training_set_ids"] || []
    training_chances = workflow.configuration["training_chances"] || []
    training_default_chance = workflow.configuration["training_default_chance"] || 0

    if Enum.count(training_set_ids) > 0 do
      training_streams = streams |> Enum.filter(&Enum.member?(training_set_ids, &1.subject_set_id))
      other_streams = streams |> Enum.reject(&Enum.member?(training_set_ids, &1.subject_set_id))

      training_stream_amount = Enum.sum(Enum.map(training_streams, &(&1.amount)))
      other_stream_amount = Enum.sum(Enum.map(other_streams, &(&1.amount)))

      training_stream = training_streams |> StreamTools.interleave
      other_stream = other_streams |> StreamTools.interleave

      number_seen_subjects = Enum.count(seen_subject_ids)
      training_chance = Enum.at(training_chances, number_seen_subjects, training_default_chance)

      training = %SubjectStream{stream: training_stream, amount: training_stream_amount, chance: training_chance}
      other = %SubjectStream{stream: other_stream, amount: other_stream_amount, chance: 1 - training_chance}
      [training, other]
    else
      streams
    end
  end
end
