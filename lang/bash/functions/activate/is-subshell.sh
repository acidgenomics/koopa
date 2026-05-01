#!/usr/bin/env bash

_koopa_is_subshell() {
    [[ "${KOOPA_SUBSHELL:-0}" -gt 0 ]]
}
