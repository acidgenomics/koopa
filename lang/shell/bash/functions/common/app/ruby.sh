#!/usr/bin/env bash

koopa::configure_ruby() { # {{{1
    # """
    # Configure Ruby.
    # @note Updated 2021-05-25.
    # """
    local name_fancy prefix version
    koopa::activate_ruby
    koopa::assert_is_installed 'ruby'
    name_fancy='Ruby'
    version="$(koopa::get_version 'ruby')"
    prefix="$(koopa::ruby_packages_prefix "$version")"
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
    koopa::activate_ruby
    koopa::configure_success "$name_fancy" "$prefix"
    return 0
}
