#!/usr/bin/env bash

# FIXME Confirm that this works, after changing koopa_find.
koopa_linux_find_app_symlinks() { # {{{1
    # """
    # Find application symlinks.
    # @note Updated 2022-02-17.
    # """
    local app dict symlink symlinks
    koopa_assert_has_args_le "$#" 2
    declare -A app=(
        [grep]="$(koopa_locate_grep)"
        [realpath]="$(koopa_locate_realpath)"
        [sort]="$(koopa_locate_sort)"
        [tail]="$(koopa_locate_tail)"
        [xargs]="$(koopa_locate_xargs)"
    )
    declare -A dict=(
        [koopa_prefix]="$(koopa_koopa_prefix)"
        [make_prefix]="$(koopa_make_prefix)"
        [name]="${1:?}"
        [version]="${2:-}"
    )
    # Automatically detect version, if left unset.
    dict[app_prefix]="$(koopa_app_prefix)/${dict[name]}"
    koopa_assert_is_dir "${dict[app_prefix]}"
    if [[ -n "${dict[version]}" ]]
    then
        dict[app_prefix]="${dict[app_prefix]}/${dict[version]}"
    else
        dict[app_prefix]="$( \
            koopa_find \
                --max-depth=1 \
                --prefix="${dict[app_prefix]}" \
                --sort \
                --type='d' \
            | "${app[tail]}" --lines=1 \
        )"
    fi
    koopa_assert_is_dir "${dict[app_prefix]}"
    readarray -t -d '' symlinks < <(
        koopa_find \
            --prefix="${dict[make_prefix]}" \
            --print0 \
            --type='l' \
        | "${app[xargs]}" \
            --no-run-if-empty \
            --null \
            "${app[realpath]}" --zero \
        | "${app[grep]}" \
            --extended-regexp \
            --null \
            --null-data \
            "^${dict[app_prefix]}/" \
        | "${app[sort]}" --zero-terminated \
    )
    if koopa_is_array_empty "${symlinks[@]}"
    then
        koopa_stop "Failed to find symlinks for '${dict[name]}'."
    fi
    for symlink in "${symlinks[@]}"
    do
        koopa_print "${symlink//${dict[app_prefix]}/${dict[make_prefix]}}"
    done
    return 0
}
