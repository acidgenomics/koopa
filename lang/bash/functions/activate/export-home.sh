#!/usr/bin/env bash

_koopa_export_home() {
    [[ -z "${HOME:-}" ]] && HOME="$(pwd)"
    export HOME
    return 0
}
