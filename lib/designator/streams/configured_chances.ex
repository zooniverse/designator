defmodule Designator.Streams.ConfiguredChances do
  alias Designator.SubjectStream

  def apply_weights(streams, workflow, _user) do
    configured_set_chances = workflow.configuration["subject_set_chances"] || %{}

    Enum.map streams, fn (stream) ->
      case get_config(stream.subject_set_id, configured_set_chances) do
        nil -> stream
        chance -> %SubjectStream{stream | chance: chance}
      end
    end
  end

  def get_config(subject_set_id, configuration) do
    configuration[to_string(subject_set_id)]
  end
end
