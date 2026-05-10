#!/usr/bin/env zsh

_koopa_export_home() {
    [[ -z "${HOME:-}" ]] && HOME="$(pwd)"
    export HOME
    return 0
}
