#!/usr/bin/env bash

# FIXME Can we get this to build on macOS?

koopa::linux_install_neovim() { # {{{1
    koopa::linux_install_app \
        --name='neovim' \
        "$@"
}

koopa:::install_neovim() { # {{{1
    # """
    # Install Neovim.
    # @note Updated 2021-04-28.
    # """
    local file jobs name prefix url version
    koopa::assert_is_linux
    prefix="${INSTALL_PREFIX:?}"
    version="${INSTALL_VERSION:?}"
    name='neovom'
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
