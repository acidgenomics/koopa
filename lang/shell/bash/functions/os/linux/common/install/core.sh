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

# NOTE Consider making this in a function that we can also use on macOS.
# FIXME Need to rework using koopa::find here...
koopa::linux_find_app_symlinks() { # {{{1
    # """
    # Find application symlinks.
    # @note Updated 2021-05-20.
    # """
    local app_prefix koopa_prefix make_prefix file links name version
    koopa::assert_has_args "$#"
    koopa::assert_has_args_le "$#" 2
    koopa::assert_is_linux
    name="${1:?}"
    version="${2:-}"
    koopa_prefix="$(koopa::prefix)"
    make_prefix="$(koopa::make_prefix)"
    # Automatically detect version, if left unset.
    app_prefix="$(koopa::app_prefix)/${name}"
    koopa::assert_is_dir "$app_prefix"
    if [[ -n "$version" ]]
    then
        app_prefix="${app_prefix}/${version}"
    else
        # FIXME GNU sort, tail
        app_prefix="$( \
            koopa::find \
                --prefix="$app_prefix" \
                --max-depth=1 \
                --type='d' \
            | sort \
            | tail -n 1 \
        )"
    fi
    # Pipe GNU find into array.
    # FIXME GNU sort, tail
    readarray -t links <<< "$( \
        find -L "$make_prefix" \
            -type f \
            -path "${app_prefix}/*" \
            ! -path "$koopa_prefix" \
            -print0 \
        | sort -z \
    )"
    # Replace the cellar prefix with our build prefix.
    for file in "${links[@]}"
    do
        koopa::print "${file//$app_prefix/$make_prefix}"
    done
    return 0
}
