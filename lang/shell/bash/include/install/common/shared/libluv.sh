#!/usr/bin/env bash

main() {
    # """
    # Install libluv.
    # @note Updated 2023-04-04.
    #
    # Currently only using this in Neovim installer with LuaJIT.
    #
    # @seealso
    # - https://github.com/luvit/luv
    # - https://github.com/Homebrew/homebrew-core/blob/HEAD/Formula/luv.rb
    # - cmake/Modules/FindLua.cmake
    # - cmake/Modules/FindLuaJIT.cmake
    # """
    local -A app cmake dict
    local -a cmake_args deps
    deps=('libuv' 'luajit')
    koopa_activate_app "${deps[@]}"
    app['luajit']="$(koopa_locate_luajit)"
    koopa_assert_is_executable "${app[@]}"
    dict['libuv']="$(koopa_app_prefix 'libuv')"
    dict['luajit']="$(koopa_app_prefix 'luajit')"
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['shared_ext']="$(koopa_shared_ext)"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    dict['luajit_ver']="$(koopa_get_version "${app['luajit']}")"
    dict['luajit_maj_min_ver']="$( \
        koopa_major_minor_version "${dict['luajit_ver']}" \
    )"
    koopa_assert_is_dir \
        "${dict['libuv']}" \
        "${dict['luajit']}"
    cmake['libuv_include_dir']="${dict['libuv']}/include"
    cmake['libuv_libraries']="${dict['libuv']}/lib/\
libuv.${dict['shared_ext']}"
    cmake['luajit_include_dir']="${dict['luajit']}/include/\
luajit-${dict['luajit_maj_min_ver']}"
    cmake['luajit_libraries']="${dict['luajit']}/lib/\
libluajit.${dict['shared_ext']}"
    koopa_assert_is_dir \
        "${cmake['libuv_include_dir']}" \
        "${cmake['luajit_include_dir']}"
    koopa_assert_is_file \
        "${cmake['libuv_libraries']}" \
        "${cmake['luajit_libraries']}"
    cmake_args=(
        # Build options --------------------------------------------------------
        '-DBUILD_MODULE=ON'
        '-DBUILD_SHARED_LIBS=ON'
        '-DBUILD_STATIC_LIBS=ON'
        '-DLUA_BUILD_TYPE=System'
        '-DLUA_COMPAT53_DIR=deps/lua-compat-5.3'
        '-DWITH_LUA_ENGINE=LuaJIT'
        '-DWITH_SHARED_LIBUV=ON'
        # Dependency paths -----------------------------------------------------
        "-DLIBUV_INCLUDE_DIR=${cmake['libuv_include_dir']}"
        "-DLIBUV_LIBRARIES=${cmake['libuv_libraries']}"
        "-DLUAJIT_INCLUDE_DIR=${cmake['luajit_include_dir']}"
        "-DLUAJIT_LIBRARIES=${cmake['luajit_libraries']}"
    )
    # Download libluv source code.
    dict['luv_url']="https://github.com/luvit/luv/archive/\
${dict['version']}.tar.gz"
    koopa_download "${dict['luv_url']}"
    koopa_extract \
        "$(koopa_basename "${dict['luv_url']}")" \
        'src'
    # Download 'lua-compat-5.3', which is required for LuaJIT.
    dict['lua_compat_url']="https://github.com/keplerproject/lua-compat-5.3/\
archive/v0.10.tar.gz"
    koopa_download "${dict['lua_compat_url']}"
    koopa_extract \
        "$(koopa_basename "${dict['lua_compat_url']}")" \
        'lua-compat-src'
    koopa_cp \
        --target-directory='src/deps/lua-compat-5.3' \
        'lua-compat-src'/*
    koopa_cd 'src'
    koopa_mkdir "${dict['prefix']}/lib"
    koopa_cmake_build --prefix="${dict['prefix']}" "${cmake_args[@]}"
    return 0
}
