#!/bin/bash

# set REVISION env var from commit_id.txt or default
COMMIT_ID=$(cat commit_id.txt 2> /dev/null)
REVISION="${COMMIT_ID:-asdf123jkl456}"

# ensure we stop on error (-e) and log cmds (-x)
set -ex
ERLANG_NODE_NAME=${ERLANG_NODE_NAME:-erlang@designator.zooniverse.org}
ERLANG_DISTRIBUTED_PORT=${ERLANG_DISTRIBUTED_PORT:-9001}
# enable the SMP (multiprocessing) for erlang VM, https://docs.riak.com/riak/kv/latest/using/performance/erlang/index.html#smp
ERLANG_SMP=${ERLANG_SMP:-auto}
ERLANG_KERNEL_OPTS=${ERLANG_KERNEL_OPTS:-"inet_dist_listen_min ${ERLANG_DISTRIBUTED_PORT} inet_dist_listen_max ${ERLANG_DISTRIBUTED_PORT}"}
ERLANG_OPTS="-smp ${ERLANG_SMP} -kernel ${ERLANG_KERNEL_OPTS}"
PORT=${PORT:-80}
# run the elixir app via Erlang VM
exec env PORT=$PORT elixir --name $ERLANG_NODE_NAME --cookie $SECRET_KEY_BASE --erl "${ERLANG_OPTS}" -S mix phoenix.server
