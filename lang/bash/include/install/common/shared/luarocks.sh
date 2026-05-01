#!/usr/bin/env bash

main() {
    # """
    # Install Luarocks.
    # @note Updated 2023-04-10.
    # """
    local -A app dict
    local -a conf_args
    _koopa_activate_app --build-only 'unzip'
    _koopa_activate_app 'lua'
    app['lua']="$(_koopa_locate_lua)"
    _koopa_assert_is_executable "${app[@]}"
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    dict['lua_version']="$(_koopa_get_version "${app['lua']}")"
    dict['lua_maj_min_ver']="$( \
        _koopa_major_minor_version "${dict['lua_version']}" \
    )"
    conf_args=(
        "--lua-version=${dict['lua_maj_min_ver']}"
        "--prefix=${dict['prefix']}"
    )
    dict['url']="https://luarocks.org/releases/\
luarocks-${dict['version']}.tar.gz"
    _koopa_download "${dict['url']}"
    _koopa_extract "$(_koopa_basename "${dict['url']}")" 'src'
    _koopa_cd 'src'
    _koopa_make_build "${conf_args[@]}"
    return 0
}
