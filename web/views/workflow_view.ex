defmodule Cellect.WorkflowView do
  use Cellect.Web, :view

  def render("show.json", %{subjects: subjects}) do
    subjects
  end
end
