defmodule Designator.RootView do
  use Designator.Web, :view

  def render("index.json", %{status: status}) do
    status
  end
end
