#!/usr/bin/env bash

# FIXME Move this into a separate file.
koopa::variable() { # {{{1
    # """
    # Return a variable stored 'variables.txt' include file.
    # @note Updated 2021-05-25.
    #
    # This approach handles inline comments.
    # """
    local cut file grep head include_prefix key value
    cut="$(koopa::locate_cut)"
    grep="$(koopa::locate_grep)"
    head="$(koopa::locate_head)"
    key="${1:?}"
    include_prefix="$(koopa::include_prefix)"
    file="${include_prefix}/variables.txt"
    koopa::assert_is_file "$file"
    value="$( \
        "$grep" -Eo "^${key}=\"[^\"]+\"" "$file" \
        || koopa::stop "'${key}' not defined in '${file}'." \
    )"
    value="$( \
        koopa::print "$value" \
            | "$head" -n 1 \
            | "$cut" -d '"' -f 2 \
    )"
    [[ -n "$value" ]] || return 1
    koopa::print "$value"
    return 0
}
