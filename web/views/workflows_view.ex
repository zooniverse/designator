defmodule Cellect.WorkflowsView do
  use Cellect.Web, :view

  def render("index.json", %{subjects: subjects}) do
    subjects
  end
end
