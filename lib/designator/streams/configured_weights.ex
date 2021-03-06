defmodule Designator.Streams.ConfiguredWeights do
  alias Designator.SubjectStream

  def apply_weights(streams, workflow, user) do
    workflow_config = workflow.configuration["subject_set_weights"] || %{}
    user_config = user.configuration["subject_set_weights"] || %{}

    Enum.map streams, fn (stream) ->
      case get_weight(stream.subject_set_id, workflow_config, user_config) do
        nil -> stream
        weight -> %SubjectStream{stream | chance: stream.chance * weight}
      end
    end
  end

  defp get_weight(subject_set_id, workflow_config, user_config) do
    key = to_string(subject_set_id)
    user_config[key] || workflow_config[key]
  end
end
