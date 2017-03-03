defmodule Designator.WorkflowView do
  use Designator.Web, :view

  def render("show.json", %{subjects: subjects}) do
    subjects
  end
end
