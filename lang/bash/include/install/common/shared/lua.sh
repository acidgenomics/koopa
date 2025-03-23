#!/usr/bin/env bash

# NOTE Need to improve build to include dylib.
# See Homebrew recipe for details.

main() {
    # """
    # Install Lua.
    # @note Updated 2024-07-15.
    #
    # @seealso
    # - http://www.lua.org/manual/
    # - https://github.com/Homebrew/legacy-homebrew/pull/5043
    # """
    local -A app dict
    koopa_activate_app --build-only 'make' 'pkg-config'
    app['make']="$(koopa_locate_make)"
    koopa_assert_is_executable "${app[@]}"
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    if koopa_is_macos
    then
        dict['platform']='macosx'
    elif koopa_is_linux
    then
        dict['platform']='linux'
    fi
    dict['url']="https://www.lua.org/ftp/lua-${dict['version']}.tar.gz"
    koopa_download "${dict['url']}"
    koopa_extract "$(koopa_basename "${dict['url']}")" 'src'
    koopa_cd 'src'
    koopa_print_env
    "${app['make']}" "${dict['platform']}"
    "${app['make']}" install INSTALL_TOP="${dict['prefix']}"
    return 0
}
