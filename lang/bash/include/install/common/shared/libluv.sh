#!/usr/bin/env bash

main() {
    # """
    # Install libluv.
    # @note Updated 2023-04-10.
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
    _koopa_activate_app "${deps[@]}"
    app['luajit']="$(_koopa_locate_luajit)"
    _koopa_assert_is_executable "${app[@]}"
    dict['libuv']="$(_koopa_app_prefix 'libuv')"
    dict['luajit']="$(_koopa_app_prefix 'luajit')"
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['shared_ext']="$(_koopa_shared_ext)"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    dict['luajit_ver']="$(_koopa_get_version "${app['luajit']}")"
    dict['luajit_maj_min_ver']="$( \
        _koopa_major_minor_version "${dict['luajit_ver']}" \
    )"
    _koopa_assert_is_dir \
        "${dict['libuv']}" \
        "${dict['luajit']}"
    cmake['libuv_include_dir']="${dict['libuv']}/include"
    cmake['libuv_libraries']="${dict['libuv']}/lib/\
libuv.${dict['shared_ext']}"
    cmake['luajit_include_dir']="${dict['luajit']}/include/\
luajit-${dict['luajit_maj_min_ver']}"
    cmake['luajit_libraries']="${dict['luajit']}/lib/\
libluajit.${dict['shared_ext']}"
    _koopa_assert_is_dir \
        "${cmake['libuv_include_dir']}" \
        "${cmake['luajit_include_dir']}"
    _koopa_assert_is_file \
        "${cmake['libuv_libraries']}" \
        "${cmake['luajit_libraries']}"
    cmake_args=(
        # Build options --------------------------------------------------------
        '-DBUILD_MODULE=ON'
        '-DBUILD_SHARED_LIBS=ON'
        '-DBUILD_STATIC_LIBS=OFF'
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
    _koopa_download "${dict['luv_url']}"
    _koopa_extract \
        "$(_koopa_basename "${dict['luv_url']}")" \
        'src'
    # Download 'lua-compat-5.3', which is required for LuaJIT.
    dict['lua_compat_url']="https://github.com/keplerproject/lua-compat-5.3/\
archive/v0.10.tar.gz"
    _koopa_download "${dict['lua_compat_url']}"
    _koopa_extract \
        "$(_koopa_basename "${dict['lua_compat_url']}")" \
        'lua-compat-src'
    _koopa_cp \
        --target-directory='src/deps/lua-compat-5.3' \
        'lua-compat-src'/*
    _koopa_cd 'src'
    _koopa_mkdir "${dict['prefix']}/lib"
    _koopa_cmake_build --prefix="${dict['prefix']}" "${cmake_args[@]}"
    return 0
}
