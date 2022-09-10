#!/usr/bin/env bash

# FIXME mpack is failing to build.
#lmpack.c:721:3: error: implicitly declaring library function 'snprintf' with type 'int (char *, unsigned long, const char *, ...)' [-Werror,-Wimplicit-function-declaration]
#                snprintf(errmsg, 50, "can't serialize object of type %d", type);
#                ^
#lmpack.c:721:3: note: include the header <stdio.h> or explicitly provide a declaration for 'snprintf'
#1 error generated.
#
#Error: Build error: Failed compiling object lmpack.o
#Installing https://luarocks.org/mpack-1.0.9-0.src.rock
#
#env MACOSX_DEPLOYMENT_TARGET=11.0 gcc -O2 -fPIC -I/opt/koopa/app/lua/5.4.4/include -c lmpack.c -o lmpack.o

main() {
    # """
    # Install Luarocks.
    # @note Updated 2022-09-10.
    #
    # @seealso
    # - https://github.com/luarocks/luarocks/issues/422
    # - https://github.com/gphoto/libgphoto2/issues/633
    # """
    local app conf_args dict
    koopa_assert_has_no_args "$#"
    koopa_activate_build_opt_prefix 'unzip'
    koopa_activate_opt_prefix 'lua'
    declare -A app=(
        ['lua']="$(koopa_locate_lua)"
        ['make']="$(koopa_locate_make)"
    )
    [[ -x "${app['lua']}" ]] || return 1
    [[ -x "${app['make']}" ]] || return 1
    declare -A dict=(
        ['name']='luarocks'
        ['prefix']="${KOOPA_INSTALL_PREFIX:?}"
        ['version']="${KOOPA_INSTALL_VERSION:?}"
    )
    dict['lua_version']="$(koopa_get_version "${app['lua']}")"
    dict['lua_maj_min_ver']="$(koopa_major_minor_version "${dict['lua_version']}")"
    dict['file']="${dict['name']}-${dict['version']}.tar.gz"
    dict['url']="https://luarocks.org/releases/${dict['file']}"
    koopa_download "${dict['url']}" "${dict['file']}"
    koopa_extract "${dict['file']}"
    koopa_cd "${dict['name']}-${dict['version']}"
    conf_args=(
        "--prefix=${dict['prefix']}"
        "--lua-version=${dict['lua_maj_min_ver']}"
    )
    ./configure --help
    ./configure "${conf_args[@]}"
    "${app['make']}" build
    "${app['make']}" install
    # FIXME Isolate these rocks in lmod and neovim packages instead.
    # > app['luarocks']="${dict['prefix']}/bin/luarocks"
    # > koopa_assert_is_installed "${app['luarocks']}"
    # > if koopa_is_macos
    # > then
    # >     # This fix is needed for mpack to build.
    # >     CFLAGS="-D_DARWIN_C_SOURCE ${CFLAGS:-}"
    # >     export CFLAGS
    # > fi
    # FIXME Harden our config by version pinning here.
    # > (
    # >     koopa_cd "${dict['prefix']}"
    # >     # Lmod dependencies.
    # >     "${app['luarocks']}" install 'luaposix'
    # >     "${app['luarocks']}" install 'luafilesystem'
    # >     # Neovim dependencies.
    # >     # FIXME Either this is the wrong name or not available for Lua 5.4.
    # >     # FIXME bit is available for LuaJIT, so maybe we need to use that instead.
    # >     # https://github.com/neovim/neovim/issues/11352
    # >     # https://bitop.luajit.org/
    # >     # FIXME Not available for Lua, need to use LuaJIT.
    # >     # Not sure how to do this argh....
    # >     "${app['luarocks']}" install 'bitop'
    # >     "${app['luarocks']}" install 'lpeg'
    # >     "${app['luarocks']}" install 'mpack'
    # > )
    return 0
}
