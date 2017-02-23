defmodule Cellect.StatusView do
  use Cellect.Web, :view

  def render("index.json", %{status: status}) do
    status
  end
end
