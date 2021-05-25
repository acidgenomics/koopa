#!/usr/bin/env bash

koopa::locate_gcc() { # {{{1
    # """
    # Locate GNU gcc.
    # @note Updated 2021-05-25.
    # """
    local version
    version="$(koopa::variable 'gcc')"
    version="$(koopa::major_version "$version")"
    koopa:::locate_app "gcc@${version}" "gcc-${version}" "$@"
}
