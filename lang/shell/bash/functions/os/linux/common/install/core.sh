#!/usr/bin/env bash

koopa::linux_delete_broken_app_symlinks() { # {{{1
    # """
    # Delete broken application symlinks.
    # @note Updated 2020-11-23.
    # """
    koopa::assert_has_no_args "$#"
    koopa::assert_is_linux
    koopa::delete_broken_symlinks "$(koopa::make_prefix)"
    return 0
}

# FIXME Rework using app/dict approach.
koopa::linux_find_app_symlinks() { # {{{1
    # """
    # Find application symlinks.
    # @note Updated 2021-05-26.
    # """
    local app_prefix find koopa_prefix make_prefix file links name
    local sort tail version
    koopa::assert_has_args "$#"
    koopa::assert_has_args_le "$#" 2
    koopa::assert_is_linux
    name="${1:?}"
    version="${2:-}"
    koopa_prefix="$(koopa::koopa_prefix)"
    make_prefix="$(koopa::make_prefix)"
    find="$(koopa::locate_find)"
    sort="$(koopa::locate_sort)"
    tail="$(koopa::locate_tail)"
    # Automatically detect version, if left unset.
    app_prefix="$(koopa::app_prefix)/${name}"
    koopa::assert_is_dir "$app_prefix"
    if [[ -n "$version" ]]
    then
        app_prefix="${app_prefix}/${version}"
    else
        # FIXME Use '--sort' flag in find call here instead.
        # FIXME Always sort using print0?
        app_prefix="$( \
            koopa::find \
                --prefix="$app_prefix" \
                --max-depth=1 \
                --type='d' \
            | "$sort" \
            | "$tail" -n 1 \
        )"
    fi
    # Pipe GNU find into array.
    # FIXME Need to rework this using koopa::find.
    readarray -t links <<< "$( \
        "$find" -L "$make_prefix" \
            -type f \
            -path "${app_prefix}/*" \
            ! -path "$koopa_prefix" \
            -print0 \
        | "$sort" -z \
    )"
    # Replace the cellar prefix with our build prefix.
    for file in "${links[@]}"
    do
        koopa::print "${file//$app_prefix/$make_prefix}"
    done
    return 0
}
