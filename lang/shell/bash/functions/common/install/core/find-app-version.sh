#!/usr/bin/env bash

# FIXME Need to update and wrap tail here.
koopa::find_app_version() { # {{{1
    # """
    # Find the latest application version.
    # @note Updated 2021-05-25.
    # """
    local find name prefix sort tail x
    koopa::assert_has_args "$#"
    find="$(koopa::locate_find)"
    sort="$(koopa::locate_sort)"
    tail="$(koopa::locate_tail)"
    name="${1:?}"
    prefix="$(koopa::app_prefix)"
    koopa::assert_is_dir "$prefix"
    prefix="${prefix}/${name}"
    koopa::assert_is_dir "$prefix"
    # FIXME Rework using 'koopa::find'.
    x="$( \
        "$find" "$prefix" \
            -mindepth 1 \
            -maxdepth 1 \
            -type 'd' \
        | "$sort" \
        | "$tail" -n 1 \
    )"
    [[ -d "$x" ]] || return 1
    x="$(koopa::basename "$x")"
    koopa::print "$x"
    return 0
}
