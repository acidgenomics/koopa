#!/usr/bin/env bash

koopa::configure_go() { # {{{1
    # """
    # Configure Go.
    # @note Updated 2021-05-25.
    # """
    local name_fancy version
    koopa::activate_go
    koopa::assert_is_installed 'go'
    name_fancy='Go'
    version="$(koopa::get_version 'go')"
    version="$(koopa::major_minor_version "$version")"
    prefix="$(koopa::go_packages_prefix "$version")"
    koopa::configure_start "$name_fancy" "$prefix"
    if [[ ! -d "$prefix" ]]
    then
        koopa::sys_mkdir "$prefix"
        (
            koopa::sys_set_permissions "$(koopa::dirname "$prefix")"
            koopa::cd "$(koopa::dirname "$prefix")"
            koopa::sys_ln "$(koopa::basename "$prefix")" 'latest'
        )
    fi
    koopa::activate_go
    koopa::configure_success "$name_fancy" "$prefix"
    return 0
}
