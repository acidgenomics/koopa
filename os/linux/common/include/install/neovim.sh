#!/usr/bin/env bash

install_neovim() { # {{{1
    # """
    # Install Neovim.
    # @note Updated 2021-04-28.
    # """
    local file jobs name prefix url version
    koopa::assert_is_linux
    name="${INSTALL_NAME:?}"
    prefix="${INSTALL_PREFIX:?}"
    version="${INSTALL_VERSION:?}"
    jobs="$(koopa::cpu_count)"
    file="v${version}.tar.gz"
    url="https://github.com/${name}/${name}/archive/${file}"
    koopa::download "$url"
    koopa::extract "$file"
    koopa::cd "${name}-${version}"
    make \
        --jobs="$jobs" \
        CMAKE_BUILD_TYPE='Release' \
        CMAKE_INSTALL_PREFIX="$prefix"
    make install
    return 0
}

install_neovim "$@"
