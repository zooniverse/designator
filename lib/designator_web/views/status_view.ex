defmodule DesignatorWeb.StatusView do
  use DesignatorWeb, :view

  def render("index.json", %{status: status}) do
    status
  end
end
