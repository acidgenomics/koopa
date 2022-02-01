#!/usr/bin/env bash

koopa::linux_find_app_symlinks() { # {{{1
    # """
    # Find application symlinks.
    # @note Updated 2022-02-01.
    # """
    local app dict symlink symlinks
    koopa::assert_has_args_le "$#" 2
    declare -A app=(
        [find]="$(koopa::locate_find)"  # FIXME Take out (see below)
        [sort]="$(koopa::locate_sort)"  # FIXME Take out (see below)
        [tail]="$(koopa::locate_tail)"
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
    # FIXME Need to rework this using koopa::find.
    readarray -t symlinks <<< "$( \
        "${app[find]}" -L "${dict[make_prefix]}" \
            -type 'f' \
            -path "${dict[app_prefix]}/*" \
            ! -path "${dict[koopa_prefix]}" \
            -print0 \
        | "${app[sort]}" -z \
    )"
    if koopa::is_array_empty "${symlinks[@]}"
    then
        koopa::stop "Failed to find symlinks for '${dict[name]}'."
    fi
    # Replace the cellar prefix with our build prefix.
    koopa::dl \
        'app_prefix' "${dict[app_prefix]}" \
        'make_prefix' "${dict[make_prefix]}"
    for symlink in "${symlinks[@]}"
    do
        koopa::print "$symlink"
        # FIXME This substition approach doesn't work...
        # FIXME Need to confirm that this new approach works.
        koopa::print "${symlink//${dict[app_prefix]}/${dict[make_prefix]}}"
    done
    return 0
}
