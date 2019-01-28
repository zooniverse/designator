FROM elixir:1.8

# ENV LANG en_US.UTF-8
# ENV LANGUAGE en_US:en
# ENV LC_ALL en_US.UTF-8
ENV MIX_ENV prod

ADD . /app
WORKDIR /app
RUN mix local.hex --force
RUN mix local.rebar --force
RUN mix deps.get
RUN mix compile
CMD ["bash", "entrypoint.sh"]
