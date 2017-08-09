defmodule DesignatorWeb.WorkflowView do
  use DesignatorWeb, :view

  def render("show.json", %{subjects: subjects}) do
    subjects
  end
end
