FROM elixir:1.8-slim

WORKDIR /app

ADD mix.exs /app
ADD mix.lock /app
RUN mix local.hex --force
RUN mix local.rebar --force
RUN mix deps.get

ADD . /app

# Check for a commit_id.txt file: if missing, use default
RUN export COMMIT_ID=$(cat commit_id.txt)
RUN REVISION="${COMMIT_ID:-asdf123jkl456}"
ENV REVISION=$REVISION

ENV MIX_ENV prod

RUN mix compile

CMD ["/app/start.sh"]
