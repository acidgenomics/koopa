#!/usr/bin/env bash

# FIXME Rework to use 'liblua.so' instead of 'liblua.a' in a future update.

main() {
    # """
    # Install libluv.
    # @note Updated 2022-09-09.
    #
    # @seealso
    # - https://github.com/luvit/luv
    # - https://github.com/Homebrew/homebrew-core/blob/HEAD/Formula/luv.rb
    # - cmake/Modules/FindLua.cmake
    # - cmake/Modules/FindLuaJIT.cmake
    # """
    local app cmake_args dict
    koopa_activate_build_opt_prefix 'cmake'
    koopa_activate_opt_prefix 'libuv' 'lua' 'luajit'
    declare -A app
    app['cmake']="$(koopa_locate_cmake)"
    [[ -x "${app['cmake']}" ]] || return 1
    declare -A dict=(
        ['libuv']="$(koopa_app_prefix 'libuv')"
        ['lua']="$(koopa_app_prefix 'lua')"
        ['luajit']="$(koopa_app_prefix 'luajit')"
        ['name']='luv'
        ['prefix']="${KOOPA_INSTALL_PREFIX:?}"
        ['shared_ext']="$(koopa_shared_ext)"
        ['version']="${KOOPA_INSTALL_VERSION:?}"
    )
    koopa_assert_is_dir \
        "${dict['libuv']}" \
        "${dict['lua']}" \
        "${dict['luajit']}"
    dict['file']="${dict['version']}.tar.gz"
    dict['url']="https://github.com/luvit/luv/archive/${dict['file']}"
    koopa_download "${dict['url']}" "${dict['file']}"
    koopa_extract "${dict['file']}"
    koopa_cd "${dict['name']}-${dict['version']}"
    # Lua no longer builds with pkg-config support by default.
    CFLAGS="-I${dict['lua']}/include ${CFLAGS:-}"
    export CFLAGS
    cmake_args=(
        '-DBUILD_MODULE=ON'
        "-DCMAKE_CXX_FLAGS=${CPPFLAGS:-}"
        "-DCMAKE_C_FLAGS=${CFLAGS:-}"
        "-DCMAKE_EXE_LINKER_FLAGS=${LDFLAGS:-}"
        "-DCMAKE_INSTALL_PREFIX=${dict['prefix']}"
        "-DCMAKE_INSTALL_RPATH=${dict['prefix']}/lib"
        "-DCMAKE_MODULE_LINKER_FLAGS=${LDFLAGS:-}"
        "-DCMAKE_SHARED_LINKER_FLAGS=${LDFLAGS:-}"
        '-DLUA_BUILD_TYPE=System'
        '-DWITH_SHARED_LIBUV=ON'
        "-DLIBUV_INCLUDE_DIR=${dict['libuv']}/include"
        "-DLIBUV_LIBRARIES=${dict['libuv']}/lib/libuv.${dict['shared_ext']}"
    )
    "${app['cmake']}" -HL -S . -B 'buildjit' \
        "${cmake_args[@]}" \
        '-DBUILD_SHARED_LIBS=ON' \
        '-DBUILD_STATIC_LIBS=ON' \
        '-DWITH_LUA_ENGINE=LuaJIT' \
        "-DLUAJIT_INCLUDE_DIR=${dict['luajit']}/include" \
        "-DLUAJIT_LIBRARIES=${dict['luajit']}/lib/\
libluajit.${dict['shared_ext']}"
    "${app['cmake']}" -HL -S . -B 'buildlua' \
        "${cmake_args[@]}" \
        '-DBUILD_SHARED_LIBS=OFF' \
        '-DBUILD_STATIC_LIBS=OFF' \
        '-DWITH_LUA_ENGINE=Lua' \
        "-DLUA_INCLUDE_DIR=${dict['lua']}/include" \
        "-DLUA_LIBRARIES=${dict['lua']}/lib/liblua.a"
    "${app['cmake']}" --build 'buildjit'
    "${app['cmake']}" --build 'buildlua'
    "${app['cmake']}" --install 'buildjit'
    "${app['cmake']}" --install 'buildlua'
    return 0
}
