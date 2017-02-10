defmodule Cellect.Workflow.Worker do
  use GenServer

  def start_link(workflow_id) do
    subject_ids = workflow_id |> Cellect.Subject.unretired_ids |> Enum.into(Array.new)
    retired_ids = HashSet.new

    GenServer.start_link __MODULE__, {subject_ids, retired_ids}
  end

  def get(pid) do
    GenServer.call pid, :get
  end

  def retire(pid, subject_id) do
    GenServer.cast pid, {:retire, subject_id}
  end

  ####
  # Genserver implementation

  def handle_call(:get, _from, {subject_ids, retired_ids}) do
    {:reply, {subject_ids, retired_ids}, {subject_ids, retired_ids}}
  end

  def handle_cast({:retire, subject_id}, _from, {subject_ids, retired_ids}) do
    {:noreply, {subject_ids, HashSet.put(retired_ids, subject_id)}}
  end

end
