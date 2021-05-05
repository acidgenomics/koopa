#!/usr/bin/env bash

koopa::linux_install_lua() { # {{{1
    koopa::linux_install_app \
        --name='lua' \
        --name-fancy='Lua' \
        "$@"
}

koopa:::linux_install_lua() { # {{{1
    # """
    # Install Lua.
    # @note Updated 2021-04-28.
    # @seealso
    # - http://www.lua.org/manual/5.3/readme.html
    # """
    local file name prefix url version
    koopa::assert_is_linux
    prefix="${INSTALL_PREFIX:?}"
    version="${INSTALL_VERSION:?}"
    name='lua'
    file="${name}-${version}.tar.gz"
    url="http://www.${name}.org/ftp/${file}"
    koopa::download "$url"
    koopa::extract "$file"
    koopa::cd "${name}-${version}"
    make linux
    make test
    make install INSTALL_TOP="$prefix"
    return 0
}
