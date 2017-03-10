# Designator

## Operations

Opening a debug UI:

  * Find cookie secret in `s3://zooniverse-code/production_configs/cellect_ex/environment_production` (same as `SECRET_KEY_BASE`)
  * `iex --name observer@127.0.0.1 --cookie COOKIE_VALUE`
  * `:observer.start`
  * Menu Node -> Connect
  * `cellectex@misc.panoptes.zooniverse.org`
  
Now you can browse through and inspect the state of things through the Applications tab.

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

Running a benchmark:

  * First of all, compile a production-like version of the app, since the dev server will be doing code reloads and a whole bunch of other things:
  * `MIX_ENV=bench PORT=4000 POSTGRES_USER=marten POSTGRES_HOST=localhost DESIGNATOR_AUTH_PASSWORD=foo elixir -pa _build/bench/consolidated -S mix phoenix.server`
  * `brew install siege`
  * `siege -d1 -c100 -t20s http://localhost:4000/api/workflows/338\?strategy\=weighted`
