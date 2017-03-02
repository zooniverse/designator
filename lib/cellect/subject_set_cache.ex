defmodule Cellect.SubjectSetCache do
  use Supervisor

  @reloader Application.get_env(:cellect, :reloader)

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

  defstruct [:workflow_id, :subject_set_id, :subject_ids, :reloading]

  def status do
    :subject_set_cache
    |> ConCache.ets
    |> :ets.tab2list
    |> Enum.map(fn({_, val}) ->
      %{workflow_id: val.workflow_id,
        subject_set_id: val.subject_set_id,
        available: Array.size(val.subject_ids)
        }
    end)
  end

  def get({workflow_id, subject_set_id} = key) do
    subject_set = ConCache.get_or_store(:subject_set_cache, key, fn() ->
      %__MODULE__{
        workflow_id: workflow_id,
        subject_set_id: subject_set_id,
        subject_ids: Array.new
      }
    end)

    if Array.size(subject_set.subject_ids) == 0 do
      reload(key)
    end

    subject_set
  end

  def set(key, subject_set) do
    ConCache.put(:subject_set_cache, key, subject_set)
  end

  def reload(key) do
    ConCache.update(:subject_set_cache, key, fn(subject_set) ->
      {:ok, %__MODULE__{subject_set | reloading: true}}
    end)

    @reloader.reload_subject_set(key)
  end

  def unlock(key) do
    ConCache.update(:subject_set_cache, key, fn(subject_set) ->
      {:ok, %__MODULE__{subject_set | reloading: false}}
    end)
  end

  def set_subject_ids(key, subject_ids) do
    ConCache.update(:subject_set_cache, key, fn(subject_set) ->
      {:ok, %__MODULE__{subject_set | subject_ids: subject_ids, reloading: false}}
    end)
  end
end
