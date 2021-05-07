#!/usr/bin/env bash

koopa::install_lua() { # {{{1
    koopa::install_app \
        --name='lua' \
        --name-fancy='Lua' \
        "$@"
}

koopa:::install_lua() { # {{{1
    # """
    # Install Lua.
    # @note Updated 2021-05-06.
    # @seealso
    # - http://www.lua.org/manual/5.3/readme.html
    # """
    local file name platform prefix url version
    prefix="${INSTALL_PREFIX:?}"
    version="${INSTALL_VERSION:?}"
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
    koopa::download "$url"
    koopa::extract "$file"
    koopa::cd "${name}-${version}"
    make "$platform"
    make test
    make install INSTALL_TOP="$prefix"
    return 0
}
