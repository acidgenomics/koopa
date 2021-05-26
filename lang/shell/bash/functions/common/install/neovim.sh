#!/usr/bin/env bash

koopa::install_neovim() { # {{{1
    koopa::install_app \
        --name='neovim' \
        "$@"
}

koopa:::install_neovim() { # {{{1
    # """
    # Install Neovim.
    # @note Updated 2021-05-26.
    # """
    local file jobs make name prefix url version
    prefix="${INSTALL_PREFIX:?}"
    version="${INSTALL_VERSION:?}"
    jobs="$(koopa::cpu_count)"
    make="$(koopa::locate_make)"
    name='neovim'
    file="v${version}.tar.gz"
    url="https://github.com/${name}/${name}/archive/${file}"
    koopa::download "$url"
    koopa::extract "$file"
    koopa::cd "${name}-${version}"
    "$make" \
        --jobs="$jobs" \
        CMAKE_BUILD_TYPE='Release' \
        CMAKE_INSTALL_PREFIX="$prefix"
    "$make" install
    return 0
}
