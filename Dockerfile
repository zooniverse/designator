FROM elixir:1.8-slim

WORKDIR /app

RUN apt-get update && apt-get -y upgrade && \
    apt-get install --no-install-recommends -y \
    # git is required for installing packages from git repos
    ca-certificates \
    git && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

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
