#!/usr/bin/env bash

_koopa_activate_julia() {
    [[ -x "${KOOPA_PREFIX:?}/bin/julia" ]] || return 0
    JULIA_DEPOT_PATH="${HOME:?}/.julia"
    JULIA_NUM_THREADS="${KOOPA_CPU_COUNT:?}"
    export JULIA_DEPOT_PATH JULIA_NUM_THREADS
    return 0
}
