defmodule Cellect.Router do
  use Cellect.Web, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", Cellect do
    pipe_through :api
  end
end
