#!/usr/bin/env bash

_koopa_add_make_prefix_link() {
    # """
    # Ensure 'koopa' is linked inside make prefix.
    # @note Updated 2023-05-01.
    #
    # This is particularly useful for external scripts that source koopa header.
    # This approach works nicely inside a hardened R environment.
    # """
    local -A dict
    _koopa_assert_has_args_le "$#" 1
    _koopa_assert_is_admin
    dict['koopa_prefix']="${1:-}"
    dict['make_prefix']='/usr/local'
    if [[ -z "${dict['koopa_prefix']}" ]]
    then
        dict['koopa_prefix']="$(_koopa_koopa_prefix)"
    fi
    dict['source_link']="${dict['koopa_prefix']}/bin/koopa"
    dict['target_link']="${dict['make_prefix']}/bin/koopa"
    [[ -d "${dict['make_prefix']}" ]] || return 0
    [[ -L "${dict['target_link']}" ]] && return 0
    _koopa_alert "Adding 'koopa' link inside '${dict['make_prefix']}'."
    _koopa_ln --sudo "${dict['source_link']}" "${dict['target_link']}"
    return 0
}
