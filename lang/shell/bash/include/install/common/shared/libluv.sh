#!/usr/bin/env bash

main() {
    # """
    # Install libluv.
    # @note Updated 2022-09-09.
    #
    # Currently only using this in Neovim installer with LuaJIT.
    #
    # @seealso
    # - https://github.com/luvit/luv
    # - https://github.com/Homebrew/homebrew-core/blob/HEAD/Formula/luv.rb
    # - cmake/Modules/FindLua.cmake
    # - cmake/Modules/FindLuaJIT.cmake
    # """
    local app cmake_args deps dict
    koopa_activate_build_opt_prefix 'cmake'
    deps=(
        'libuv'
        # > 'lua'
        'luajit'
    )
    koopa_activate_opt_prefix "${deps[@]}"
    declare -A app=(
        ['cmake']="$(koopa_locate_cmake)"
        ['luajit']="$(koopa_locate_luajit)"
    )
    [[ -x "${app['cmake']}" ]] || return 1
    [[ -x "${app['luajit']}" ]] || return 1
    declare -A dict=(
        ['libuv']="$(koopa_app_prefix 'libuv')"
        # > ['lua']="$(koopa_app_prefix 'lua')"
        ['luajit']="$(koopa_app_prefix 'luajit')"
        ['name']='luv'
        ['prefix']="${KOOPA_INSTALL_PREFIX:?}"
        ['shared_ext']="$(koopa_shared_ext)"
        ['version']="${KOOPA_INSTALL_VERSION:?}"
    )
    koopa_assert_is_dir \
        "${dict['libuv']}" \
        "${dict['luajit']}"
    dict['luajit_ver']="$(koopa_get_version "${app['luajit']}")"
    dict['luajit_maj_min_ver']="$( \
        koopa_major_minor_version "${dict['luajit_ver']}" \
    )"
    # Download libluv source code.
    dict['file']="${dict['version']}.tar.gz"
    dict['url']="https://github.com/luvit/luv/archive/${dict['file']}"
    koopa_download "${dict['url']}" "${dict['file']}"
    koopa_extract "${dict['file']}"
    # Download 'lua-compat-5.3', which is required for LuaJIT.
    dict['file']='v0.10.tar.gz'
    dict['url']="https://github.com/keplerproject/lua-compat-5.3/\
archive/${dict['file']}"
    koopa_download "${dict['url']}" "${dict['file']}"
    koopa_extract "${dict['file']}"
    koopa_cp \
        --target-directory="${dict['name']}-${dict['version']}/\
deps/lua-compat-5.3" \
        'lua-compat-5.3-0.10'/*
    koopa_cd "${dict['name']}-${dict['version']}"
    # Lua no longer builds with pkg-config support by default.
    # > CFLAGS="-I${dict['lua']}/include ${CFLAGS:-}"
    # > export CFLAGS
    koopa_mkdir "${dict['prefix']}/lib"
    cmake_args=(
        # > "-DCMAKE_CXX_FLAGS=${CPPFLAGS:-}"
        '-DBUILD_MODULE=ON'
        "-DCMAKE_C_FLAGS=${CFLAGS:-}"
        "-DCMAKE_EXE_LINKER_FLAGS=${LDFLAGS:-}"
        "-DCMAKE_INSTALL_PREFIX=${dict['prefix']}"
        "-DCMAKE_INSTALL_RPATH=${dict['prefix']}/lib"
        "-DCMAKE_MODULE_LINKER_FLAGS=${LDFLAGS:-}"
        "-DCMAKE_SHARED_LINKER_FLAGS=${LDFLAGS:-}"
        '-DLUA_BUILD_TYPE=System'
        '-DLUA_COMPAT53_DIR=deps/lua-compat-5.3'
        '-DWITH_SHARED_LIBUV=ON'
        "-DLIBUV_INCLUDE_DIR=${dict['libuv']}/include"
        "-DLIBUV_LIBRARIES=${dict['libuv']}/lib/libuv.${dict['shared_ext']}"
    )
    # Lua support.
    # NOTE May want to link to shared object instead of 'liblua.a' in the
    # future, but this requires an update to the Lua install script.
    # > "${app['cmake']}" -HL -S . -B 'buildlua' \
    # >     "${cmake_args[@]}" \
    # >     '-DBUILD_SHARED_LIBS=OFF' \
    # >     '-DBUILD_STATIC_LIBS=OFF' \
    # >     '-DWITH_LUA_ENGINE=Lua' \
    # >     "-DLUA_INCLUDE_DIR=${dict['lua']}/include" \
    # >     "-DLUA_LIBRARIES=${dict['lua']}/lib/liblua.a"
    # > "${app['cmake']}" --build 'buildlua'
    # > "${app['cmake']}" --install 'buildlua'
    # LuaJIT support (for neovim).
    "${app['cmake']}" -HL -S . -B 'buildjit' \
        "${cmake_args[@]}" \
        '-DBUILD_SHARED_LIBS=ON' \
        '-DBUILD_STATIC_LIBS=ON' \
        '-DWITH_LUA_ENGINE=LuaJIT' \
        "-DLUAJIT_INCLUDE_DIR=${dict['luajit']}/include/\
luajit-${dict['luajit_maj_min_ver']}" \
        "-DLUAJIT_LIBRARIES=${dict['luajit']}/lib/\
libluajit.${dict['shared_ext']}"
    "${app['cmake']}" --build 'buildjit'
    "${app['cmake']}" --install 'buildjit'
    return 0
}
