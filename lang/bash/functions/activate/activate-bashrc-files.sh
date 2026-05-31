#!/usr/bin/env bash

_koopa_activate_bashrc_files() {
    # """
    # Activate personal and work specific bashrc files.
    # @note Updated 2026-03-23.
    # """
    if [[ -f '/etc/bashrc' ]]
    then
        # shellcheck source=/dev/null
        source '/etc/bashrc'
    fi
    if [[ -d "${HOME}/.bashrc.d" ]]
    then
        local rc_file
        for rc_file in "${HOME}/.bashrc.d/"*
        do
            if [[ -f "$rc_file" ]]
            then
                # shellcheck source=/dev/null
                source "$rc_file"
            fi
        done
    fi
    if [[ -f "${HOME}/.bashrc-personal" ]]
    then
        # shellcheck source=/dev/null
        source "${HOME}/.bashrc-personal"
    fi
    if [[ -f "${HOME}/.bashrc-work" ]]
    then
        # shellcheck source=/dev/null
        source "${HOME}/.bashrc-work"
    fi
    return 0
}
