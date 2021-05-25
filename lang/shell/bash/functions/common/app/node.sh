#!/usr/bin/env bash

koopa::configure_node() { # {{{1
    # """
    # Configure Node.js (and NPM).
    # @note Updated 2021-05-25.
    # @seealso
    # > npm config get prefix
    # """
    local version
    koopa::assert_is_installed 'node'
    name_fancy='Node.js'
    version="$(koopa::get_version 'node')"
    version="$(koopa::major_minor_version "$version")"
    prefix="$(koopa::node_packages_prefix "$version")"
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
    koopa::activate_node
    koopa::configure_success "$name_fancy" "$prefix"
    return 0
}
