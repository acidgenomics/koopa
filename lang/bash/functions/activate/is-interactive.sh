#!/usr/bin/env bash

_koopa_is_interactive() {
    if [[ "${KOOPA_INTERACTIVE:-0}" -eq 1 ]]
    then
        return 0
    fi
    if [[ "${KOOPA_FORCE:-0}" -eq 1 ]]
    then
        return 0
    fi
    if _koopa_str_detect_posix "$-" 'i'
    then
        return 0
    fi
    if _koopa_is_tty
    then
        return 0
    fi
    return 1
}
