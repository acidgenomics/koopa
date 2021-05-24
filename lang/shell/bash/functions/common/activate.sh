#!/usr/bin/env bash

koopa::activate_homebrew_opt_prefix() { # {{{1
    # """
    # Activate Homebrew opt prefix.
    # @note Updated 2021-05-24.
    # """
    local name opt_prefix prefix
    koopa::assert_has_args "$#"
    opt_prefix="$(koopa::homebrew_prefix)/opt"
    for name in "$@"
    do
        prefix="${opt_prefix}/${name}"
        koopa::assert_is_dir "$prefix"
        koopa::activate_prefix "$prefix"
    done
    return 0
}

koopa::activate_opt_prefix() { # {{{1
    # """
    # Activate koopa opt prefix.
    # @note Updated 2021-05-24.
    #
    # @examples
    # koopa::activate_opt_prefix proj gdal
    # """
    local name opt_prefix prefix
    koopa::assert_has_args "$#"
    opt_prefix="$(koopa::opt_prefix)"
    for name in "$@"
    do
        prefix="${opt_prefix}/${name}"
        koopa::assert_is_dir "$prefix"
        koopa::activate_prefix "$prefix"
    done
    return 0
}
