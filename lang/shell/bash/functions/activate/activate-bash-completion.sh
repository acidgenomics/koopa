#!/usr/bin/env bash

koopa_activate_bash_completion() {
    # """
    # Activate Bash completion.
    # @note Updated 2022-02-04.
    # """
    local dict
    [[ "$#" -eq 0 ]] || return 1
    declare -A dict=(
        [make_prefix]="$(koopa_make_prefix)"
        [nounset]="$(koopa_boolean_nounset)"
    )
    dict[script]="${dict[make_prefix]}/etc/profile.d/bash_completion.sh"
    [[ -r "${dict[script]}" ]] || return 0
    if [[ "${dict[nounset]}" -eq 1 ]]
    then
        set +o errexit
        set +o nounset
    fi
    # shellcheck source=/dev/null
    source "${dict[script]}"
    if [[ "${dict[nounset]}" -eq 1 ]]
    then
        set -o errexit
        set -o nounset
    fi
    return 0
}
