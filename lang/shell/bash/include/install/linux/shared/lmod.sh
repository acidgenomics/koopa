#!/usr/bin/env bash

# FIXME Need to install isolated luarocks: luafilesystem, luaposix.

main() {
    # """
    # Install Lmod.
    # @note Updated 2022-09-12.
    #
    # @seealso
    # - https://lmod.readthedocs.io/en/latest/030_installing.html
    # """
    local app dict
    koopa_activate_build_opt_prefix 'pkg-config'
    koopa_activate_opt_prefix \
        'zlib' \
        'lua' \
        'luarocks' \
        'tcl-tk'
    declare -A app=(
        ['lua']="$(koopa_locate_lua --realpath)"
        ['luarocks']="$(koopa_locate_luarocks --realpath)"
        ['make']="$(koopa_locate_make)"
    )
    [[ -x "${app['lua']}" ]] || return 1
    [[ -x "${app['luarocks']}" ]] || return 1
    [[ -x "${app['make']}" ]] || return 1
    declare -A dict=(
        ['jobs']="$(koopa_cpu_count)"
        ['make_prefix']="$(koopa_make_prefix)"
        ['name2']='Lmod'
        ['name']='lmod'
        ['prefix']="${KOOPA_INSTALL_PREFIX:?}"
        ['version']="${KOOPA_INSTALL_VERSION:?}"
    )
    dict['apps_dir']="${dict['prefix']}/apps"
    dict['data_dir']="${dict['prefix']}/moduleData"
    dict['file']="${dict['version']}.tar.gz"
    dict['url']="https://github.com/TACC/${dict['name2']}/archive/${dict['file']}"
    koopa_download "${dict['url']}" "${dict['file']}"
    koopa_extract "${dict['file']}"
    koopa_cd "${dict['name2']}-${dict['version']}"
    # FIXME Need to install isolated luaposix and luafilesystem here.
    # Refer to our draft neovim recipe for inspiration.
    # FIXME Don't use this approach, as it can put unwanted lua scripts
    # into the path coming from /usr/local...
    eval "$("${app['luarocks']}" path)"
    koopa_dl \
        'LUA_PATH' "${LUA_PATH:?}" \
        'LUA_CPATH' "${LUA_CPATH:?}"
    # > koopa_dl \
    # >     'LUA_PATH' "$("${app['lua']}" -e 'print(package.path)')" \
    # >     'LUA_CPATH' "$("${app['lua']}" -e 'print(package.cpath)')"
    conf_args=(
        "--prefix=${dict['apps_dir']}"
        "--with-spiderCacheDir=${dict['data_dir']}/cacheDir"
        "--with-updateSystemFn=${dict['data_dir']}/system.txt"
    )
    koopa_print_env
    koopa_dl 'configure args' "${conf_args[*]}"
    ./configure --help
    ./configure "${conf_args[@]}"
    "${app['make']}" VERBOSE=1 --jobs="${dict['jobs']}"
    "${app['make']}" install
    if koopa_is_admin
    then
        koopa_linux_configure_lmod "${dict['prefix']}"
    fi
    return 0
}
