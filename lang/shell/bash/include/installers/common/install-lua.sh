#!/usr/bin/env bash

koopa:::install_lua() { # {{{1
    # """
    # Install Lua.
    # @note Updated 2021-12-09.
    #
    # @seealso
    # - http://www.lua.org/manual/5.3/readme.html
    # """
    local app dict
    declare -A app=(
        [make]="$(koopa::locate_make)"
    )
    declare -A dict=(
        [name]='lua'
        [prefix]="${INSTALL_PREFIX:?}"
        [version]="${INSTALL_VERSION:?}"
    )
    dict[file]="${dict[name]}-${dict[version]}.tar.gz"
    dict[url]="http://www.lua.org/ftp/${dict[file]}"
    if koopa::is_macos
    then
        dict[platform]='macosx'
    elif koopa::is_linux
    then
        dict[platform]='linux'
    fi
    koopa::download "${dict[url]}" "${dict[file]}"
    koopa::extract "${dict[file]}"
    koopa::cd "${dict[name]}-${dict[version]}"
    "${app[make]}" "${dict[platform]}"
    "${app[make]}" test
    "${app[make]}" install INSTALL_TOP="${dict[prefix]}"
    return 0
}
