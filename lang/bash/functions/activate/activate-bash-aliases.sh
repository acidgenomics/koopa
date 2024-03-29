#!/usr/bin/env bash

_koopa_activate_bash_aliases() {
    # """
    # Alias definitions.
    # @note Updated 2022-02-04.
    #
    # See /usr/share/doc/bash-doc/examples in the bash-doc package.
    # """
    local -A dict
    dict['user_aliases_file']="${HOME}/.bash_aliases"
    if [[ -f "${dict['user_aliases_file']}" ]]
    then
        # shellcheck source=/dev/null
        source "${dict['user_aliases_file']}"
    fi
    return 0
}
