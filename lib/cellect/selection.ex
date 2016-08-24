defmodule Cellect.Selection do
  alias Cellect.StreamTools
  alias Cellect.SubjectStream

  def select(style, workflow_id, user_id), do: select(style, workflow_id, user_id, 5)

  def select("uniform", workflow_id, user_id, amount) do
    streams = Cellect.Cache.SubjectIds.get(workflow_id) |> Enum.map(&Cellect.SubjectStream.build/1)
    seen_subject_ids = Cellect.User.seen_subject_ids(workflow_id, user_id) |> Enum.into(MapSet.new)

    do_select(streams, seen_subject_ids, amount)
  end

  def select("weighted", workflow_id, user_id, amount) do
    case Cellect.Workflow.find(workflow_id) do
      nil -> []
      workflow ->
        seen_subject_ids = Cellect.User.seen_subject_ids(workflow_id, user_id) |> Enum.into(MapSet.new)
        gold_standard_set_ids = workflow.configuration["gold_standard_sets"]

        streams = Cellect.Cache.SubjectIds.get(workflow_id) |> Enum.map(&Cellect.SubjectStream.build/1)
        gold_stream = Enum.filter(streams, &Enum.member?(gold_standard_set_ids, &1.subject_set_id)) |> StreamTools.interleave
        test_stream = Enum.reject(streams, &Enum.member?(gold_standard_set_ids, &1.subject_set_id)) |> StreamTools.interleave

        gold = %SubjectStream{stream: gold_stream, chance: gold_chance(Enum.count(seen_subject_ids))}
        test = %SubjectStream{stream: test_stream, chance: 1-gold_chance(Enum.count(seen_subject_ids))}

        do_select([gold, test], seen_subject_ids, amount)
    end
  end

  def do_select(streams, seen_subject_ids, amount) do
    streams
    |> Cellect.StreamTools.interleave
    |> deduplicate
    |> reject_recently_retired
    |> reject_recently_selected
    |> reject_seen_subjects(seen_subject_ids)
    |> Enum.take(amount) # TODO: Breaks if not enough match
  end

  def gold_chance(n) when n in  0..20, do: 0.4
  def gold_chance(n) when n in 21..40, do: 0.3
  def gold_chance(n) when n in 41..60, do: 0.2
  def gold_chance(_),                  do: 0.1

  def deduplicate(stream) do
    Stream.uniq(stream)
  end

  def reject_recently_retired(stream) do
    stream #TODO
  end

  def reject_recently_selected(stream) do
    stream #TODO
  end

  def reject_seen_subjects(stream, seen_subject_ids) do
    Stream.reject(stream, fn x -> MapSet.member?(seen_subject_ids, x) end)
  end
end
