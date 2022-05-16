#!/usr/bin/env bash

koopa_which_function() {
    # """
    # Locate a koopa function automatically.
    # @note Updated 2022-04-29.
    # """
    local dict
    koopa_assert_has_args_eq "$#" 1
    [[ -z "${1:-}" ]] && return 1
    declare -A dict=(
        [input_key]="${1:?}"
    )
    if koopa_is_function "${dict[input_key]}"
    then
        koopa_print "${dict[input_key]}"
        return 0
    fi
    dict[key]="${dict[input_key]//-/_}"
    dict[os_id]="$(koopa_os_id)"
    if koopa_is_function "koopa_${dict[os_id]}_${dict[key]}"
    then
        dict[fun]="koopa_${dict[os_id]}_${dict[key]}"
    elif koopa_is_rhel_like && \
        koopa_is_function "koopa_rhel_${dict[key]}"
    then
        dict[fun]="koopa_rhel_${dict[key]}"
    elif koopa_is_debian_like && \
        koopa_is_function "koopa_debian_${dict[key]}"
    then
        dict[fun]="koopa_debian_${dict[key]}"
    elif koopa_is_fedora_like && \
        koopa_is_function "koopa_fedora_${dict[key]}"
    then
        dict[fun]="koopa_fedora_${dict[key]}"
    elif koopa_is_linux && \
        koopa_is_function "koopa_linux_${dict[key]}"
    then
        dict[fun]="koopa_linux_${dict[key]}"
    else
        dict[fun]="koopa_${dict[key]}"
    fi
    koopa_is_function "${dict[fun]}" || return 1
    koopa_print "${dict[fun]}"
    return 0
}
