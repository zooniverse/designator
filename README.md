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

  * `docker-compose down --rmi all -v --remove-orphans`
  * `docker-compose build`
  * `docker-compose run web mix ecto.create`
  * `docker-compose run test mix deps.get`
  * `docker-compose run test mix test`
  * `docker-compose up` and `curl http://localhost:4000/api`

  Interactively debug the tests
  ```
  docker-compose run test bash
  iex -S mix test --trace
  mix test --only wip
  ```

Running a benchmark:

  * First of all, compile a production-like version of the app, since the dev server will be doing code reloads and a whole bunch of other things:
  * `MIX_ENV=bench PORT=4000 POSTGRES_USER=marten POSTGRES_HOST=localhost DESIGNATOR_AUTH_PASSWORD=foo elixir -pa _build/bench/consolidated -S mix phoenix.server`
  * `brew install siege`
  * `siege -d1 -c100 -t20s http://localhost:4000/api/workflows/338\?strategy\=weighted`

### How HTTP traffic drives selection

1. Routes are defined in, see  [router.ex](web/router.ex)
    + all the API routes accept JSON request formats

** Public API **

0. `GET /api/workflows` hits the [workflows controller](web/controllers/workflow_controller.ex) show action
    + All subject selection happens from this end point.

** BASIC AUTH Protected routes **
Some routes are protected to ensure only authenticated users can request them, i.e. downstream selection caller.

1. `POST /api/workflows/:id/reload`
    + Reload the workflow data from source db.
    + This will set `SubjectSetCache` `reloading_since` to avoid concurrent reloading data requests.
0. `POST /api/workflows/:id/unlock`
    + Unlock a reloading workflow, remove the `SubjectSetCache` `reloading_since` lock.
0. `POST /api/workflows/:id/remove?subject_id=1`
    + Remove the subject_id from the available subject_ids for selection (retire it)
    + The subject ID can be sent as a JSON payload or a query param
    + This will force a full reload after 50 requests to ensure the system has the latest known state of the data available for selection.

### Internal selection pipeline

Once a HTTP request is received via the API the `Designator.Selection.select` function is invoked with the selection params.

This will call `get_streams` after loading data from relevant caches (Workflow, User seens). Get Streams is important as it creates a pipe of known selection builders that combine to:
  1. Get Subjects from cache
  0. reject empty data sets
  0. filter the streams based on rule sets of the known implementations (apply weights, select with chance, add gold standard)

After data from the streams is compiled it's passed to `do_select` to extract the data as well as reject specific subject ids i.e. seen, retired, recently selected.

The `do_select` function uses `Designator.StreamTools.interleave`, this is a an engine to iterate through a set of streams and pluck items (up to a limit) using the wired. This should not really have to be touched and is an optimized version (lazily evaluated) of get all items and take up to a limit.

Once the `Designator.StreamTools.interleave` functions are wired up other functions are added to ensure we don't return, duplicate subject_ids or data that is retired or recently seen.

At the end of the function pipe is `Enum.take(amount)` to control the signalling of the `Designator.StreamTools.interleave` engine for extracting data from a stream. This is done by tracking a known limit being reached and signalling via the enum protocol that `Designator.StreamTools.interleave` implements.

Finally `do_select` uses a async task timeout to run selection to allow the selection from the streams to be killed if it doesn't perform quickly enough.
