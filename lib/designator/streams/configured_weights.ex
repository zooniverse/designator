defmodule Designator.Streams.ConfiguredWeights do
  alias Designator.SubjectStream

  def apply_weights(streams, workflow, _user) do
    configured_set_weights = workflow.configuration["subject_set_weights"] || %{}

    Enum.map streams, fn (stream) ->
      case get_weight(stream.subject_set_id, configured_set_weights) do
        nil -> stream
        weight -> %SubjectStream{stream | chance: stream.chance * weight}
      end
    end
  end

  def get_weight(subject_set_id, configuration) do
    configuration[to_string(subject_set_id)]
  end
end
