#!/usr/bin/env bash

_koopa_activate_bash_readline() {
    # """
    # Readline input options.
    # @note Updated 2022-02-04.
    # """
    local -A dict
    [[ -n "${INPUTRC:-}" ]] && return 0
    dict['input_rc_file']="${HOME}/.inputrc"
    [[ -r "${dict['input_rc_file']}" ]] || return 0
    export INPUTRC="${dict['input_rc_file']}"
    return 0
}
