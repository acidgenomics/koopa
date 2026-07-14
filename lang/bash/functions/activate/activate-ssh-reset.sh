#!/usr/bin/env bash

_koopa_activate_ssh_reset() {
    # """
    # Opt-in ssh() wrapper that resets terminal DEC private modes after exit.
    # @note Updated 2026-07-14.
    #
    # When an SSH session dies abruptly (e.g. transport MAC failure), remote
    # tmux may leave mouse tracking (modes 1000/1006) and color-scheme
    # reporting (mode 2031) enabled on the local terminal, causing mouse
    # clicks and OS dark/light toggles to dump escape sequences as literal
    # keystrokes into the prompt.
    #
    # Set KOOPA_SSH_RESET=1 to enable.  The wrapper is deliberately opt-in so
    # the real ssh binary remains unshadowed by default.
    #
    # Recovery without this wrapper: koopa run reset-terminal
    # """
    _koopa_is_interactive || return 0
    [[ "${KOOPA_SSH_RESET:-0}" == '1' ]] || return 0
    ssh() {
        # Run the real ssh, then unconditionally reset local terminal modes on
        # return (clean exit, error, or connection death).  'command ssh'
        # bypasses this wrapper to avoid recursion.
        command ssh "$@"
        local __koopa_ssh_status=$?
        "${KOOPA_PREFIX:?}/bin/koopa" run reset-terminal >/dev/null 2>&1
        return $__koopa_ssh_status
    }
    return 0
}
