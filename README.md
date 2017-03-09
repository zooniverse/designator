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
