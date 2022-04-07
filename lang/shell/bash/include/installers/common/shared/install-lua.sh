#!/usr/bin/env bash

install_lua() { # {{{1
    # """
    # Install Lua.
    # @note Updated 2021-12-09.
    #
    # @seealso
    # - http://www.lua.org/manual/5.3/readme.html
    # """
    local app dict
    koopa_assert_has_no_args "$#"
    declare -A app=(
        [make]="$(koopa_locate_make)"
    )
    declare -A dict=(
        [name]='lua'
        [prefix]="${INSTALL_PREFIX:?}"
        [version]="${INSTALL_VERSION:?}"
    )
    dict[file]="${dict[name]}-${dict[version]}.tar.gz"
    dict[url]="http://www.lua.org/ftp/${dict[file]}"
    if koopa_is_macos
    then
        dict[platform]='macosx'
    elif koopa_is_linux
    then
        dict[platform]='linux'
    fi
    koopa_download "${dict[url]}" "${dict[file]}"
    koopa_extract "${dict[file]}"
    koopa_cd "${dict[name]}-${dict[version]}"
    "${app[make]}" "${dict[platform]}"
    "${app[make]}" test
    "${app[make]}" install INSTALL_TOP="${dict[prefix]}"
    return 0
}
