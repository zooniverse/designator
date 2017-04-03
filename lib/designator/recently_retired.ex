defmodule Designator.RecentlyRetired do
  use Supervisor

  @cache :recently_retired_cache

  def start_link do
    Supervisor.start_link(__MODULE__, [])
  end

  def init([]) do
    children = [
      supervisor(ConCache, [[], [name: @cache]]),
    ]

    supervise(children, strategy: :one_for_one)
  end

  ### Public API

  defstruct [:workflow_id, subject_ids: MapSet.new]

  def status do
    @cache
    |> ConCache.ets
    |> :ets.tab2list
    |> Enum.map(fn({_, val}) ->
      %{workflow_id: val.id, subject_ids_size: MapSet.size(val.subject_ids)}
    end)
  end

  def get(workflow_id) do
    ConCache.get_or_store(@cache, workflow_id, fn() ->
      %__MODULE__{workflow_id: workflow_id}
    end)
  end

  def add(workflow_id, subject_id) do
    ConCache.update(@cache, workflow_id, fn(item) ->
      case item do
        nil ->
          {:ok, %__MODULE__{workflow_id: workflow_id, subject_ids: MapSet.new([subject_id])}}
        _   ->
          subject_ids = MapSet.put(item.subject_ids, subject_id)
          {:ok, %__MODULE__{item | subject_ids: subject_ids}}
      end
    end)
  end

  def clear(workflow_id) do
    ConCache.delete(@cache, workflow_id)
  end
end
