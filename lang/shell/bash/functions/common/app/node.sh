#!/usr/bin/env bash

koopa::configure_node() { # {{{1
    # """
    # Configure Node.js (and NPM).
    # @note Updated 2021-05-25.
    # """
    local version
    name_fancy='Node.js'
    version="$(koopa::get_version 'node')"
    version="$(koopa::major_minor_version "$version")"
    prefix="$(koopa::node_packages_prefix "$version")"
    koopa::configure_start "$name_fancy" "$prefix"
    echo "$prefix"
    koopa::configure_success "$name_fancy" "$prefix"
    return 0
}
