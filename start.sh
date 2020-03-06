#!/bin/bash

# ensure we stop on error (-e) and log cmds (-x)
set -ex
ERLANG_NODE_NAME=${ERLANG_NODE_NAME:-erlang@designator.zooniverse.org}
ERLANG_DISTRIBUTED_PORT=${ERLANG_DISTRIBUTED_PORT:-9001}
# enable the SMP (multiprocessing) for erlang VM, https://docs.riak.com/riak/kv/latest/using/performance/erlang/index.html#smp
ERLANG_SMP=${ERLANG_SMP:-auto}
ERLANG_KERNEL_OPTS=${ERLANG_KERNEL_OPTS:-"inet_dist_listen_min ${ERLANG_DISTRIBUTED_PORT} inet_dist_listen_max ${ERLANG_DISTRIBUTED_PORT}"}
ERLANG_OPTS="-smp ${ERLANG_SMP} -kernel ${ERLANG_KERNEL_OPTS}"
# run the elixir app via Erlang VM
exec elixir --name $ERLANG_NODE_NAME --cookie $SECRET_KEY_BASE --erl "${ERLANG_OPTS}" -S mix phoenix.server
