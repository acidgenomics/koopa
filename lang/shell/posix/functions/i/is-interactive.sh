#!/bin/sh

koopa_is_interactive() {
    # """
    # Is the current shell interactive?
    # @note Updated 2021-05-27.
    # Consider checking for tmux or subshell here.
    # """
    [ "${KOOPA_INTERACTIVE:-0}" -eq 1 ] && return 0
    [ "${KOOPA_FORCE:-0}" -eq 1 ] && return 0
    koopa_str_detect_posix "$-" 'i' && return 0
    koopa_is_tty && return 0
    return 1
}
