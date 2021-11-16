#!/usr/bin/env bash

# [2021-05-27] macOS success.

koopa::install_lua() { # {{{1
    koopa:::install_app \
        --name-fancy='Lua' \
        --name='lua' \
        "$@"
}

koopa:::install_lua() { # {{{1
    # """
    # Install Lua.
    # @note Updated 2021-05-26.
    # @seealso
    # - http://www.lua.org/manual/5.3/readme.html
    # """
    local file make name platform prefix url version
    prefix="${INSTALL_PREFIX:?}"
    version="${INSTALL_VERSION:?}"
    make="$(koopa::locate_make)"
    name='lua'
    file="${name}-${version}.tar.gz"
    url="http://www.${name}.org/ftp/${file}"
    if koopa::is_macos
    then
        platform='macosx'
    elif koopa::is_linux
    then
        platform='linux'
    fi
    koopa::download "$url" "$file"
    koopa::extract "$file"
    koopa::cd "${name}-${version}"
    "$make" "$platform"
    "$make" test
    "$make" install INSTALL_TOP="$prefix"
    return 0
}

koopa::uninstall_lua() { # {{{1
    koopa:::uninstall_app \
        --name-fancy='Lua' \
        --name='lua' \
        "$@"
}
