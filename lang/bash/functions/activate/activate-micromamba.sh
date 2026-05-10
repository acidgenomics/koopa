#!/usr/bin/env bash

_koopa_activate_micromamba() {
    if [[ -z "${MAMBA_ROOT_PREFIX:-}" ]]
    then
        export MAMBA_ROOT_PREFIX="${HOME:?}/.mamba"
    fi
    return 0
}
