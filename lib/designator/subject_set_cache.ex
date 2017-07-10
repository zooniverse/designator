defmodule Designator.SubjectSetCache do
  use Supervisor

  @reloader Application.get_env(:designator, :reloader)

  def start_link do
    Supervisor.start_link(__MODULE__, [])
  end

  def init([]) do
    children = [
      supervisor(ConCache, [[ttl_check: :timer.minutes(1),
                             ttl: :timer.hours(24),
                             touch_on_read: true],
                            [name: :subject_set_cache]]),
    ]

    supervise(children, strategy: :one_for_one)
  end

  ### Public API

  defstruct [:workflow_id, :subject_set_id, :subject_ids, :loaded_at, :reloading_since]

  def status do
    :subject_set_cache
    |> ConCache.ets
    |> :ets.tab2list
    |> Enum.map(fn({_, val}) ->
      %{workflow_id: val.workflow_id,
        subject_set_id: val.subject_set_id,
        available: Array.size(val.subject_ids),
        loaded_at: val.loaded_at,
        reloading_since: val.reloading_since
       }
    end)
  end

  def get({workflow_id, subject_set_id} = key) do
    subject_set = ConCache.get_or_store(:subject_set_cache, key, fn() ->
      %__MODULE__{
        workflow_id: workflow_id,
        subject_set_id: subject_set_id,
        subject_ids: Array.new,
        loaded_at: nil,
        reloading_since: nil
      }
    end)

    if !subject_set.loaded_at do
      reload(key)
    end

    subject_set
  end

  def set(key, subject_set) do
    ConCache.put(:subject_set_cache, key, subject_set)
  end

  def reload(key) do
    ConCache.update_existing(:subject_set_cache, key, fn(subject_set) ->
      if subject_set.reloading_since && Timex.after?(subject_set.reloading_since, Timex.shift(Timex.now, hours: -1)) do
        {:error, :already_reloading}
      else
        @reloader.reload_subject_set(key)
        {:ok, %__MODULE__{subject_set | reloading_since: DateTime.utc_now}}
      end
    end)
  end

  def unlock(key) do
    ConCache.update(:subject_set_cache, key, fn(subject_set) ->
      {:ok, %__MODULE__{subject_set | reloading_since: nil}}
    end)
  end

  def set_subject_ids(key, subject_ids) do
    ConCache.update(:subject_set_cache, key, fn(subject_set) ->
      {:ok, %__MODULE__{subject_set | subject_ids: subject_ids, loaded_at: DateTime.utc_now, reloading_since: nil}}
    end)
  end
end
