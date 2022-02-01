#!/usr/bin/env bash

koopa::linux_find_app_symlinks() { # {{{1
    # """
    # Find application symlinks.
    # @note Updated 2022-02-01.
    # """
    local app dict symlink symlinks
    koopa::assert_has_args_le "$#" 2
    declare -A app=(
        [find]="$(koopa::locate_find)"
        [grep]="$(koopa::locate_grep)"
        [realpath]="$(koopa::locate_realpath)"
        [sort]="$(koopa::locate_sort)"
        [tail]="$(koopa::locate_tail)"
        [xargs]="$(koopa::locate_xargs)"
    )
    declare -A dict=(
        [koopa_prefix]="$(koopa::koopa_prefix)"
        [make_prefix]="$(koopa::make_prefix)"
        [name]="${1:?}"
        [version]="${2:-}"
    )
    # Automatically detect version, if left unset.
    dict[app_prefix]="$(koopa::app_prefix)/${dict[name]}"
    koopa::assert_is_dir "${dict[app_prefix]}"
    if [[ -n "${dict[version]}" ]]
    then
        dict[app_prefix]="${dict[app_prefix]}/${dict[version]}"
    else
        dict[app_prefix]="$( \
            koopa::find \
                --max-depth=1 \
                --prefix="${dict[app_prefix]}" \
                --sort \
                --type='d' \
            | "${app[tail]}" -n 1 \
        )"
    fi
    koopa::assert_is_dir "${dict[app_prefix]}"
    # Pipe GNU find into array.
    # FIXME Seeing command substition, null byte here, argh...
    readarray -t -d '' symlinks <<< "$( \
        "${app[find]}" -L "${dict[make_prefix]}" \
            -xtype 'l' \
            -print0 \
        | "${app[xargs]}" --no-run-if-empty --null \
            "${app[realpath]}" --zero \
    )"
        #| "${app[grep]}" \
        #    --extended-regexp \
        #    --null \
        #    "^${dict[app_prefix]}/" \
        # | "${app[sort]}" --zero-terminated \
    if koopa::is_array_empty "${symlinks[@]}"
    then
        koopa::stop "Failed to find symlinks for '${dict[name]}'."
    fi
    for symlink in "${symlinks[@]}"
    do
        koopa::print "${symlink//${dict[app_prefix]}/${dict[make_prefix]}}"
    done
    return 0
}
