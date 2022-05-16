#!/usr/bin/env bash

koopa_activate_bash_aliases() {
    # """
    # Alias definitions.
    # @note Updated 2022-02-04.
    #
    # See /usr/share/doc/bash-doc/examples in the bash-doc package.
    # """
    local dict
    [[ "$#" -eq 0 ]] || return 1
    declare -A dict=(
        [user_aliases_file]="${HOME}/.bash_aliases"
    )
    if [[ -f "${dict[user_aliases_file]}" ]]
    then
        # shellcheck source=/dev/null
        source "${dict[user_aliases_file]}"
    fi
    return 0
}
