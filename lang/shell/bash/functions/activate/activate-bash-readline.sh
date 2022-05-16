#!/usr/bin/env bash

koopa_activate_bash_readline() {
    # """
    # Readline input options.
    # @note Updated 2022-02-04.
    # """
    local dict
    [[ "$#" -eq 0 ]] || return 1
    [[ -n "${INPUTRC:-}" ]] && return 0
    declare -A dict=(
        [input_rc_file]="${HOME}/.inputrc"
    )
    [[ -r "${dict[input_rc_file]}" ]] || return 0
    export INPUTRC="${dict[input_rc_file]}"
    return 0
}
