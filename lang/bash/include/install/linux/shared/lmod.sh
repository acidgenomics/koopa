#!/usr/bin/env bash

main() {
    # """
    # Install Lmod.
    # @note Updated 2023-03-04.
    #
    # @seealso
    # - https://lmod.readthedocs.io/en/latest/030_installing.html
    # """
    local -A app dict
    local -a rocks
    local rock
    _koopa_activate_app --build-only 'make' 'pkg-config'
    _koopa_activate_app \
        'zlib' \
        'lua' \
        'luarocks' \
        'tcl-tk'
    app['lua']="$(_koopa_locate_lua --realpath)"
    app['luac']="$(_koopa_locate_luac --realpath)"
    app['luarocks']="$(_koopa_locate_luarocks --realpath)"
    app['make']="$(_koopa_locate_make)"
    _koopa_assert_is_executable "${app[@]}"
    dict['jobs']="$(_koopa_cpu_count)"
    dict['lua']="$(_koopa_app_prefix 'lua')"
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    dict['libexec']="$(_koopa_init_dir "${dict['prefix']}/libexec")"
    dict['apps_dir']="${dict['prefix']}/apps"
    dict['data_dir']="${dict['libexec']}/moduleData"
    dict['url']="https://github.com/TACC/Lmod/archive/${dict['version']}.tar.gz"
    _koopa_download "${dict['url']}"
    _koopa_extract "$(_koopa_basename "${dict['url']}")" 'src'
    _koopa_cd 'src'
    rocks=('luaposix' 'luafilesystem')
    for rock in "${rocks[@]}"
    do
        "${app['luarocks']}" \
            --lua-dir="${dict['lua']}" \
            install \
                --tree "${dict['libexec']}" \
                "$rock"
    done
    dict['lua_ver']="$(_koopa_get_version "${app['lua']}")"
    dict['lua_compat_ver']="$(_koopa_major_minor_version "${dict['lua_ver']}")"
    lua_path_arr=(
        # > './?.lua'
        "${dict['libexec']}/share/lua/${dict['lua_compat_ver']}/?.lua"
        "${dict['libexec']}/share/lua/${dict['lua_compat_ver']}/?/init.lua"
        "${dict['lua']}/share/lua/${dict['lua_compat_ver']}/?.lua"
        "${dict['lua']}/share/lua/${dict['lua_compat_ver']}/?/init.lua"
    )
    lua_cpath_arr=(
        # > './?.so'
        "${dict['libexec']}/lib/lua/${dict['lua_compat_ver']}/?.so"
        "${dict['lua']}/lib/lua/${dict['lua_compat_ver']}/?.so"
    )
    LUAROCKS_PREFIX="${dict['libexec']}"
    LUA_PATH="$(printf '%s;' "${lua_path_arr[@]}")"
    LUA_CPATH="$(printf '%s;' "${lua_cpath_arr[@]}")"
    export LUAROCKS_PREFIX LUA_PATH LUA_CPATH
    "${app['lua']}" -e 'print(package.path)'
    "${app['lua']}" -e 'print(package.cpath)'
    conf_args=(
        "--prefix=${dict['apps_dir']}"
        '--with-allowRootUse=no'
        "--with-lua=${app['lua']}"
        "--with-luac=${app['luac']}"
        "--with-spiderCacheDir=${dict['data_dir']}/cacheDir"
        "--with-updateSystemFn=${dict['data_dir']}/system.txt"
    )
    _koopa_print_env
    _koopa_dl 'configure args' "${conf_args[*]}"
    ./configure --help
    ./configure "${conf_args[@]}"
    "${app['make']}" VERBOSE=1 --jobs="${dict['jobs']}"
    "${app['make']}" install
    return 0
}
