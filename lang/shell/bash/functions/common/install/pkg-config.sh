#!/usr/bin/env bash

koopa::install_pkg_config() { # {{{1
    koopa::install_app \
        --name='pkg-config' \
        "$@"
}

koopa:::install_pkg_config() { # {{{1
    # """
    # Install pkg-config.
    # @note Updated 2021-05-26.
    # @seealso
    # - https://www.freedesktop.org/wiki/Software/pkg-config/
    # - https://pkg-config.freedesktop.org/releases/
    # """
    local file jobs make name prefix url version
    koopa::assert_is_installed cmp diff
    prefix="${INSTALL_PREFIX:?}"
    version="${INSTALL_VERSION:?}"
    jobs="$(koopa::cpu_count)"
    make="$(koopa::locate_make)"
    name='pkg-config'
    file="${name}-${version}.tar.gz"
    url="https://${name}.freedesktop.org/releases/${file}"
    koopa::download "$url"
    koopa::extract "$file"
    koopa::cd "${name}-${version}"
    ./configure --prefix="$prefix"
    "$make" --jobs="$jobs"
    "$make" install
    return 0
}
