#!/bin/sh

_koopa_is_interactive() {
    # """
    # Is the current shell interactive?
    # @note Updated 2023-12-14.
    # Consider checking for tmux or subshell here.
    # """
    if [ "${KOOPA_INTERACTIVE:-0}" -eq 1 ]
    then
        return 0
    fi
    if [ "${KOOPA_FORCE:-0}" -eq 1 ]
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
    if [ -n "${SSH_CONNECTION:-}" ] && [ -n "${TMUX:-}" ]
    then
        return 0
    fi
    return 1
}
