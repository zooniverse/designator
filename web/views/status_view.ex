defmodule Designator.StatusView do
  use Designator.Web, :view

  def render("index.json", %{status: status}) do
    status
  end
end
