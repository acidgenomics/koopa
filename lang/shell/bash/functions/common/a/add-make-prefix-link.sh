#!/usr/bin/env bash

koopa_add_make_prefix_link() {
    # """
    # Ensure 'koopa' is linked inside make prefix.
    # @note Updated 2022-04-08.
    #
    # This is particularly useful for external scripts that source koopa header.
    # This approach works nicely inside a hardened R environment.
    # """
    local dict
    koopa_assert_has_args_le "$#" 1
    koopa_is_shared_install || return 0
    koopa_assert_is_admin
    declare -A dict=(
        [koopa_prefix]="${1:-}"
        [make_prefix]='/usr/local'
    )
    if [[ -z "${dict[koopa_prefix]}" ]]
    then
        dict[koopa_prefix]="$(koopa_koopa_prefix)"
    fi
    dict[source_link]="${dict[koopa_prefix]}/bin/koopa"
    dict[target_link]="${dict[make_prefix]}/bin/koopa"
    [[ -d "${dict[make_prefix]}" ]] || return 0
    [[ -L "${dict[target_link]}" ]] && return 0
    koopa_alert "Adding 'koopa' link inside '${dict[make_prefix]}'."
    koopa_ln --sudo "${dict[source_link]}" "${dict[target_link]}"
    return 0
}
