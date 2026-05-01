#!/usr/bin/env bash

_koopa_macos_activate_cli_colors() {
    [[ -z "${CLICOLOR:-}" ]] && export CLICOLOR=1
    return 0
}
