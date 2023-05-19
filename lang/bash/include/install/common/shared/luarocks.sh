#!/usr/bin/env bash

main() {
    # """
    # Install Luarocks.
    # @note Updated 2023-04-10.
    # """
    local -A app dict
    local -a conf_args
    koopa_activate_app --build-only 'unzip'
    koopa_activate_app 'lua'
    app['lua']="$(koopa_locate_lua)"
    koopa_assert_is_executable "${app[@]}"
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    dict['lua_version']="$(koopa_get_version "${app['lua']}")"
    dict['lua_maj_min_ver']="$( \
        koopa_major_minor_version "${dict['lua_version']}" \
    )"
    conf_args=(
        "--lua-version=${dict['lua_maj_min_ver']}"
        "--prefix=${dict['prefix']}"
    )
    dict['url']="https://luarocks.org/releases/\
luarocks-${dict['version']}.tar.gz"
    koopa_download "${dict['url']}"
    koopa_extract "$(koopa_basename "${dict['url']}")" 'src'
    koopa_cd 'src'
    koopa_make_build "${conf_args[@]}"
    return 0
}
