defmodule Designator.Streams.GoldStandard do
  alias Designator.SubjectStream
  alias Designator.StreamTools

  def apply_weights(streams, workflow, user) do
    seen_subject_ids = user.seen_ids
    gold_standard_set_ids = workflow.configuration["gold_standard_sets"] || []

    if Enum.count(gold_standard_set_ids) > 0 do
      gold_streams = streams |> Enum.filter(&Enum.member?(gold_standard_set_ids, &1.subject_set_id))
      test_streams = streams |> Enum.reject(&Enum.member?(gold_standard_set_ids, &1.subject_set_id))
      gold_stream_amount = Enum.sum(Enum.map(gold_streams, &(&1.amount)))
      test_stream_amount = Enum.sum(Enum.map(test_streams, &(&1.amount)))
      gold_stream = gold_streams |> StreamTools.interleave
      test_stream = test_streams |> StreamTools.interleave

      gold = %SubjectStream{stream: gold_stream, amount: gold_stream_amount, chance: gold_chance(Enum.count(seen_subject_ids))}
      test = %SubjectStream{stream: test_stream, amount: test_stream_amount, chance: 1 - gold_chance(Enum.count(seen_subject_ids))}
      [gold, test]
    else
      streams
    end
  end

  def gold_chance(n) when n in  0..20, do: 0.4
  def gold_chance(n) when n in 21..40, do: 0.3
  def gold_chance(n) when n in 41..60, do: 0.2
  def gold_chance(_),                  do: 0.1
end
