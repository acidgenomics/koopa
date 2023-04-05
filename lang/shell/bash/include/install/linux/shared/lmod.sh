#!/usr/bin/env bash

main() {
    # """
    # Install Lmod.
    # @note Updated 2023-03-04.
    #
    # @seealso
    # - https://lmod.readthedocs.io/en/latest/030_installing.html
    # """
    local app dict rock rocks
    declare -A app dict
    koopa_activate_app --build-only 'make' 'pkg-config'
    koopa_activate_app \
        'zlib' \
        'lua' \
        'luarocks' \
        'tcl-tk'
    app['lua']="$(koopa_locate_lua --realpath)"
    app['luac']="$(koopa_locate_luac --realpath)"
    app['luarocks']="$(koopa_locate_luarocks --realpath)"
    app['make']="$(koopa_locate_make)"
    [[ -x "${app['lua']}" ]] || exit 1
    [[ -x "${app['luarocks']}" ]] || exit 1
    [[ -x "${app['make']}" ]] || exit 1
    dict['jobs']="$(koopa_cpu_count)"
    dict['lua']="$(koopa_app_prefix 'lua')"
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    dict['libexec']="$(koopa_init_dir "${dict['prefix']}/libexec")"
    dict['apps_dir']="${dict['prefix']}/apps"
    dict['data_dir']="${dict['libexec']}/moduleData"
    dict['url']="https://github.com/TACC/Lmod/archive/${dict['version']}.tar.gz"
    koopa_download "${dict['url']}"
    koopa_extract "$(koopa_basename "${dict['url']}")" 'src'
    koopa_cd 'src'
    rocks=('luaposix' 'luafilesystem')
    for rock in "${rocks[@]}"
    do
        "${app['luarocks']}" \
            --lua-dir="${dict['lua']}" \
            install \
                --tree "${dict['libexec']}" \
                "$rock"
    done
    dict['lua_ver']="$(koopa_get_version "${app['lua']}")"
    dict['lua_compat_ver']="$(koopa_major_minor_version "${dict['lua_ver']}")"
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
    koopa_print_env
    koopa_dl 'configure args' "${conf_args[*]}"
    ./configure --help
    ./configure "${conf_args[@]}"
    "${app['make']}" VERBOSE=1 --jobs="${dict['jobs']}"
    "${app['make']}" install
    return 0
}
