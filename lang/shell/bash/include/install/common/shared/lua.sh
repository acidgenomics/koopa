#!/usr/bin/env bash

# NOTE Need to improve build to include dylib.

main() {
    # """
    # Install Lua.
    # @note Updated 2022-09-09.
    #
    # @seealso
    # - http://www.lua.org/manual/
    # - https://github.com/Homebrew/legacy-homebrew/pull/5043
    # """
    local app dict
    koopa_assert_has_no_args "$#"
    koopa_activate_opt_prefix 'pkg-config'
    declare -A app=(
        ['make']="$(koopa_locate_make)"
    )
    [[ -x "${app['make']}" ]] || return 1
    declare -A dict=(
        ['name']='lua'
        ['prefix']="${KOOPA_INSTALL_PREFIX:?}"
        ['version']="${KOOPA_INSTALL_VERSION:?}"
    )
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
