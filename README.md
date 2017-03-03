# Designator

## Development guide

Local installation:

  * `brew install elixir`
  * `mix deps.get`
  * `mix ecto.create && mix ecto.migrate`
  * `mix test`
  * `iex -S mix phoenix.server` and `curl http://localhost:4000/api`
  
Using Docker:

  * `docker-compose build`
  * `docker-compose run web mix ecto.create`
  * `docker-compose run test mix test`
  * `docker-compose up` and `curl http://localhost:4000/api`
