defmodule Cellect.SubjectsView do
  use Cellect.Web, :view

  def render("index.json", %{subjects: subjects}) do
    %{subjects: subjects}
  end
end
