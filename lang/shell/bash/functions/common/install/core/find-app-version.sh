#!/usr/bin/env bash

koopa::find_app_version() { # {{{1
    # """
    # Find the latest application version.
    # @note Updated 2021-11-11.
    # """
    local app dict
    koopa::assert_has_args_eq "$#" 1
    declare -A app=(
        [sort]="$(koopa::locate_sort)"
        [tail]="$(koopa::locate_tail)"
    )
    declare -A dict=(
        [app_prefix]="$(koopa::app_prefix)"
        [name]="${1:?}"
    )
    dict[prefix]="${dict[app_prefix]}/${dict[name]}"
    koopa::assert_is_dir "${dict[prefix]}"
    dict[hit]="$( \
        koopa::find \
            --max-depth=1 \
            --min-depth=1 \
            --prefix="${dict[prefix]}" \
            --type='d' \
        | "${app[sort]}" \
        | "${app[tail]}" -n 1 \
    )"
    [[ -d "${dict[hit]}" ]] || return 1
    dict[hit_bn]="$(koopa::basename "${dict[hit]}")"
    koopa::print "${dict[hit_bn]}"
    return 0
}
