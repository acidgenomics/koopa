#!/usr/bin/env bash

install_pkg_config() { # {{{1
    # """
    # Install pkg-config.
    # @note Updated 2021-04-27.
    # @seealso
    # - https://www.freedesktop.org/wiki/Software/pkg-config/
    # - https://pkg-config.freedesktop.org/releases/
    # """
    local file jobs name prefix url version
    koopa::assert_is_installed cmp diff
    prefix="${INSTALL_PREFIX:?}"
    version="${INSTALL_VERSION:?}"
    name='pkg-config'
    jobs="$(koopa::cpu_count)"
    file="${name}-${version}.tar.gz"
    url="https://${name}.freedesktop.org/releases/${file}"
    koopa::download "$url"
    koopa::extract "$file"
    koopa::cd "${name}-${version}"
    ./configure --prefix="$prefix"
    make --jobs="$jobs"
    make install
    return 0
}

install_pkg_config "$@"
