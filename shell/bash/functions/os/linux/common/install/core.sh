#!/usr/bin/env bash

koopa::linux_delete_broken_cellar_symlinks() { # {{{1
    # """
    # Delete broken cellar symlinks.
    # @note Updated 2020-11-18.
    # """
    koopa::assert_has_no_args "$#"
    koopa::assert_is_linux
    koopa::delete_broken_symlinks "$(koopa::make_prefix)"
    return 0
}

koopa::linux_find_cellar_symlinks() { # {{{1
    # """
    # Find cellar symlinks.
    # @note Updated 2020-11-17.
    # """
    local cellar_prefix koopa_prefix make_prefix file links name version
    koopa::assert_has_args "$#"
    koopa::assert_has_args_le "$#" 2
    koopa::assert_is_linux
    koopa::assert_is_installed find sort tail
    name="${1:?}"
    version="${2:-}"
    koopa_prefix="$(koopa::prefix)"
    make_prefix="$(koopa::make_prefix)"
    # Automatically detect version, if left unset.
    cellar_prefix="$(koopa::cellar_prefix)/${name}"
    koopa::assert_is_dir "$cellar_prefix"
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
        find -L "$make_prefix" \
            -type f \
            -path "${cellar_prefix}/*" \
            ! -path "$koopa_prefix" \
            -print0 \
        | sort -z \
    )"
    # Replace the cellar prefix with our build prefix.
    for file in "${links[@]}"
    do
        koopa::print "${file//$cellar_prefix/$make_prefix}"
    done
    return 0
}

koopa::linux_install_cellar() { # {{{1
    # """
    # Install Linux-specific cellar program.
    # @note Updated 2020-11-18.
    # """
    local script_prefix
    script_prefix="$(koopa::prefix)/os/linux/common/include/build"
    koopa::install_cellar --script-prefix="$script_prefix" "$@"
    return 0
}
