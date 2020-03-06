FROM elixir:1.8

ENV MIX_ENV prod

ADD . /app
WORKDIR /app
RUN mix local.hex --force
RUN mix local.rebar --force
RUN mix deps.get
RUN mix compile
CMD ["/app/start.sh"]
