FROM elixir:1.8

WORKDIR /app

ADD mix.exs /app
ADD mix.lock /app
RUN mix local.hex --force
RUN mix local.rebar --force
RUN mix deps.get

ADD . /app

ARG REVISION=''
ENV REVISION=$REVISION

ENV MIX_ENV prod

RUN mix compile

CMD ["/app/start.sh"]
