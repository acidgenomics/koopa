#!/usr/bin/env bash

# [2021-05-27] macOS success.

koopa::install_luarocks() { # {{{1
    koopa:::install_app \
        --name='luarocks' \
        "$@"
}

koopa:::install_luarocks() { # {{{1
    # """
    # Install Luarocks.
    # @note Updated 2021-05-26.
    # """
    local file make name lua_version prefix url version
    koopa::activate_opt_prefix 'lua'
    koopa::assert_is_installed 'lua'
    prefix="${INSTALL_PREFIX:?}"
    version="${INSTALL_VERSION:?}"
    make="$(koopa::locate_make)"
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
    "$make" build
    "$make" install
    return 0
}

koopa::uninstall_luarocks() { # {{{1
    koopa:::uninstall_app \
        --name='luarocks' \
        "$@"
}
