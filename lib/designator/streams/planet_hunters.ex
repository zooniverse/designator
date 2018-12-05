defmodule Designator.Streams.PlanetHunters do
  alias Designator.SubjectStream
  alias Designator.StreamTools

  def apply_weights(streams, workflow, user) do
    seen_count = user.seen_ids |> Enum.count
    training_set_ids = workflow.configuration["planet_hunters_training_sets"] || []

    if Enum.count(training_set_ids) > 0 do
      training_streams = streams |> Enum.filter(&Enum.member?(training_set_ids, &1.subject_set_id))
      real_streams = streams |> Enum.reject(&Enum.member?(training_set_ids, &1.subject_set_id))

      training_stream_amount = Enum.sum(Enum.map(training_streams, &(&1.amount)))
      real_stream_amount = Enum.sum(Enum.map(real_streams, &(&1.amount)))

      training_stream = training_streams |> StreamTools.interleave
      real_stream = real_streams |> StreamTools.interleave

      training = %SubjectStream{stream: training_stream, amount: training_stream_amount, chance: training_chance(seen_count)}
      real     = %SubjectStream{stream: real_stream, amount: real_stream_amount, chance: 1 - training_chance(seen_count)}
      [training, real]
    else
      streams
    end
  end

  def training_chance(n) when n in  0..15,  do: 0.33
  def training_chance(n) when n in 16..100, do: 0.05
  def training_chance(_),                  do: 0.01
end
