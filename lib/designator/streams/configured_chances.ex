defmodule Designator.Streams.ConfiguredChances do
  alias Designator.SubjectStream

  def apply_weights(streams, workflow, user) do
    workflow_config = workflow.configuration["subject_set_chances"] || %{}
    user_config = user.configuration["subject_set_chances"] || %{}

    Enum.map streams, fn (stream) ->
      case get_config(stream.subject_set_id, workflow_config, user_config) do
        nil -> stream
        chance -> %SubjectStream{stream | chance: chance}
      end
    end
  end

  defp get_config(subject_set_id, workflow_config, user_config) do
    key = to_string(subject_set_id)
    user_config[key] || workflow_config[key]
  end
end
