#!/usr/bin/env bash

# NOTE Need to improve build to include dylib.
# See Homebrew recipe for details.

main() {
    # """
    # Install Lua.
    # @note Updated 2023-04-06.
    #
    # @seealso
    # - http://www.lua.org/manual/
    # - https://github.com/Homebrew/legacy-homebrew/pull/5043
    # """
    local -A app dict
    koopa_activate_app --build-only 'make' 'pkg-config'
    app['make']="$(koopa_locate_make)"
    koopa_assert_is_executable "${app[@]}"
    dict['name']='lua'
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    dict['file']="${dict['name']}-${dict['version']}.tar.gz"
    dict['url']="http://www.lua.org/ftp/${dict['file']}"
    if koopa_is_macos
    then
        dict['platform']='macosx'
    elif koopa_is_linux
    then
        dict['platform']='linux'
    fi
    koopa_download "${dict['url']}" "${dict['file']}"
    koopa_extract "${dict['file']}"
    koopa_cd "${dict['name']}-${dict['version']}"
    koopa_print_env
    "${app['make']}" "${dict['platform']}"
    "${app['make']}" test
    "${app['make']}" install INSTALL_TOP="${dict['prefix']}"
    return 0
}
