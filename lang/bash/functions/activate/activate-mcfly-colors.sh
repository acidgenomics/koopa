#!/usr/bin/env bash

_koopa_activate_mcfly_colors() {
    if [[ "${KOOPA_COLOR_MODE:-}" == 'light' ]] && \
        ! [[ -n "${TMUX:-}" && "$OSTYPE" != darwin* ]]
    then
        export MCFLY_LIGHT=true
    else
        unset -v MCFLY_LIGHT
    fi
    return 0
}
