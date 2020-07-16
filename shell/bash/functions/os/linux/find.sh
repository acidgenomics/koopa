#!/usr/bin/env bash

koopa::find_cellar_symlinks() { # {{{1
    local build_prefix cellar_prefix file links name version
    koopa::assert_has_args_le "$#" 2
    koopa::assert_is_installed find sort tail
    name="${1:?}"
    version="${2:-}"
    build_prefix="$(koopa::make_prefix)"
    # Automatically detect version, if left unset.
    cellar_prefix="$(koopa::cellar_prefix)/${name}"
    if [[ -n "$version" ]]
    then
        cellar_prefix="${cellar_prefix}/${version}"
    else
        cellar_prefix="$( \
            find "$cellar_prefix" -maxdepth 1 -type d \
            | sort \
            | tail -n 1 \
        )"
    fi
    # Pipe GNU find into array.
    readarray -t links <<< "$( \
        find -L "$build_prefix" \
            -type f \
            -path "${cellar_prefix}/*" \
            ! -path "${build_prefix}/koopa" \
            -print0 \
        | sort -z \
    )"
    # Replace the cellar prefix with our build prefix.
    for file in "${links[@]}"
    do
        koopa::print "${file//$cellar_prefix/$build_prefix}"
    done
    return 0
}

