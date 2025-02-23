defmodule Designator.Repo do
  use Ecto.Repo,
    otp_app: :designator,
    adapter: Ecto.Adapters.Postgres
end
