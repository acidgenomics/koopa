#!/usr/bin/env bash

# FIXME Can we install on macOS?

koopa::linux_install_luarocks() { # {{{1
    koopa::install_app \
        --name='luarocks' \
        --platform='linux' \
        "$@"
}

koopa:::linux_install_luarocks() { # {{{1
    # """
    # Install Luarocks.
    # @note Updated 2021-05-04.
    # """
    local file name lua_version prefix url version
    koopa::assert_is_linux
    koopa::assert_is_installed lua
    prefix="${INSTALL_PREFIX:?}"
    version="${INSTALL_VERSION:?}"
    name='luarocks'
    lua_version="$(koopa::get_version lua)"
    lua_version="$(koopa::major_minor_version "$lua_version")"
    file="${name}-${version}.tar.gz"
    url="https://${name}.org/releases/${file}"
    koopa::download "$url"
    koopa::extract "$file"
    koopa::cd "${name}-${version}"
    ./configure \
        --prefix="$prefix" \
        --lua-version="$lua_version" \
        --versioned-rocks-dir
    make build
    make install
    return 0
}
