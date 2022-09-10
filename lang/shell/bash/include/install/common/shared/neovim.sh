#!/usr/bin/env bash

# FIXME Consider disabling Homebrew with '-DHOMEBREW_PROG='

# FIXME How to address this warning?
# /opt/koopa/app/luajit/2.1.0-beta3/bin/luajit-2.1.0-beta3: module 'jit.bcsave' not found:
# Correct file path is at:
# /opt/koopa/app/luajit/2.1.0-beta3/share/luajit-2.1.0-beta3/jit/bcsave.lua

# FIXME Now hitting a cryptic 'terminal.c' build error.
# https://github.com/neovim/neovim/issues/16217

# FIXME Need to address 'bcsave.lua' linkage issue.
# Correct path: /opt/koopa/app/luajit/2.1.0-beta3/share/luajit-2.1.0-beta3/jit/bcsave.lua

# Hitting a libluv linker issue at the end:
# 100%] Generating doc/tags
#dyld[48129]: Library not loaded: 'libluv.1.dylib'
#  Referenced from: '/private/var/folders/l1/8y8sjzmn15v49jgrqglghcfr0000gn/T/koopa-501-20220910-081109-Uee6oASjTm/neovim-0.7.2/build/bin/nvim'
#  Reason: tried: 'libluv.1.dylib' (no such file), '/usr/local/lib/libluv.1.dylib' (no such file), '/usr/lib/libluv.1.dylib' (no such file), '/private/var/folders/l1/8y8sjzmn15v49jgrqglghcfr0000gn/T/koopa-501-20220910-081109-Uee6oASjTm/neovim-0.7.2/build/runtime/libluv.1.dylib' (no such file), '/usr/local/lib/libluv.1.dylib' (no such file), '/usr/lib/libluv.1.dylib' (no such file)

main() {
    # """
    # Install Neovim.
    # @note Updated 2022-09-10.
    #
    # Homebrew is currently required for this to build on macOS.
    #
    # @seealso
    # - https://github.com/neovim/neovim/wiki/Building-Neovim
    # - https://github.com/Homebrew/homebrew-core/blob/master/Formula/neovim.rb
    # - https://github.com/neovim/neovim/issues/11192
    # - https://carlosahs.medium.com/how-to-install-neovim-from-source-on-
    #     ubuntu-20-04-lts-524b3a91b4c4
    # - https://github.com/neovim/neovim/blob/master/cmake/FindLibIntl.cmake
    # - https://github.com/facebook/hhvm/blob/master/CMake/FindLibIntl.cmake
    # - https://github.com/neovim/neovim/blob/master/cmake.deps/
    #     cmake/BuildLuarocks.cmake
    # - https://github.com/neovim/neovim/issues/930
    # - https://leafo.net/guides/customizing-the-luarocks-tree.html
    # - Notes on 'terminal.c' build failure:
    #   https://github.com/neovim/neovim/issues/16217
    #   https://github.com/neovim/neovim/pull/17329
    # - Issues related to libluv linkage:
    #   https://github.com/NixOS/nixpkgs/issues/81206
    # """
    local app cmake_args deps dict rock rocks
    koopa_assert_has_no_args "$#"
    koopa_activate_build_opt_prefix \
        'cmake' \
        'ninja' \
        'pkg-config'
    deps=(
        'm4'
        'gettext'
        'libiconv'
        'libuv'
        'luajit'
        'libluv'
        'luarocks'
        'msgpack'
        'ncurses'
        'python'
        'tree-sitter'
        'unibilium'
        'libtermkey'
        'libvterm'
    )
    koopa_activate_opt_prefix "${deps[@]}"
    declare -A app=(
        ['cmake']="$(koopa_locate_cmake)"
        ['luajit']="$(koopa_locate_luajit --realpath)"
        ['luarocks']="$(koopa_locate_luarocks --realpath)"
    )
    [[ -x "${app['cmake']}" ]] || return 1
    [[ -x "${app['luajit']}" ]] || return 1
    [[ -x "${app['luarocks']}" ]] || return 1
    declare -A dict=(
        ['gettext']="$(koopa_app_prefix 'gettext')"
        ['jobs']="$(koopa_cpu_count)"
        ['libiconv']="$(koopa_app_prefix 'libiconv')"
        ['libluv']="$(koopa_app_prefix 'libluv')"
        ['libtermkey']="$(koopa_app_prefix 'libtermkey')"
        ['libuv']="$(koopa_app_prefix 'libuv')"
        ['libvterm']="$(koopa_app_prefix 'libvterm')"
        ['luajit']="$(koopa_app_prefix 'luajit')"
        ['msgpack']="$(koopa_app_prefix 'msgpack')"
        ['name']='neovim'
        ['prefix']="${KOOPA_INSTALL_PREFIX:?}"
        ['shared_ext']="$(koopa_shared_ext)"
        ['tree_sitter']="$(koopa_app_prefix 'tree-sitter')"
        ['unibilium']="$(koopa_app_prefix 'unibilium')"
        ['version']="${KOOPA_INSTALL_VERSION:?}"
    )
    koopa_assert_is_dir \
        "${dict['gettext']}" \
        "${dict['libiconv']}" \
        "${dict['libluv']}" \
        "${dict['libtermkey']}" \
        "${dict['libuv']}" \
        "${dict['libvterm']}" \
        "${dict['luajit']}" \
        "${dict['msgpack']}" \
        "${dict['tree_sitter']}" \
        "${dict['unibilium']}"
    dict['libexec']="${dict['prefix']}/libexec"
    koopa_mkdir "${dict['libexec']}"
    # Install LuaJIT dependency rocks.
    dict['luajit_ver']="$(koopa_get_version "${app['luajit']}")"
    dict['luajit_ver2']="$(koopa_basename "${dict['luajit']}")"
    dict['luajit_maj_min_ver']="$( \
        koopa_major_minor_version "${dict['luajit_ver']}" \
    )"
    if koopa_is_macos
    then
        export CFLAGS="${CFLAGS:-}"
        CFLAGS_BAK="$CFLAGS"
        # This fix is needed for Lua mpack rock to build.
        CFLAGS="-D_DARWIN_C_SOURCE ${CFLAGS:-}"
    fi
    rocks=(
        'lpeg'
        # > 'luv'
        'mpack'
    )
    for rock in "${rocks[@]}"
    do
        "${app['luarocks']}" \
            --lua-dir="${dict['luajit']}" \
            install \
                --tree "${dict['libexec']}" \
                "$rock"
    done
    if koopa_is_macos
    then
        CFLAGS="$CFLAGS_BAK"
    fi
    # This step sets 'LUA_PATH' and 'LUA_CPATH' environment variables.
    # But it also puts '/usr/local' into path, so disabling this approach.
    # > eval "$( \
    # >     "${app['luarocks']}" \
    # >         --lua-dir="${dict['luajit']}" \
    # >         path \
    # > )"
    dict['lua_compat_ver']='5.1'
    lua_path_arr=(
        "${dict['libexec']}/share/lua/${dict['lua_compat_ver']}/?.lua"
        "${dict['luajit']}/share/luajit-${dict['luajit_ver2']}/?.lua"
    )
    lua_cpath_arr=(
        "${dict['libexec']}/lib/lua/${dict['lua_compat_ver']}/?.so"
        "${dict['luajit']}/lib/lua/${dict['lua_compat_ver']}/?.so"
    )
    LUA_PATH="$(printf '%s;' "${lua_path_arr[@]}")"
    LUA_CPATH="$(printf '%s;' "${lua_cpath_arr[@]}")"
    export LUA_PATH LUA_CPATH
    koopa_dl \
        'LUA_PATH' "${LUA_PATH:?}" \
        'LUA_CPATH' "${LUA_CPATH:?}"
    # FIXME This doesn't make libluv accessible in linker during final build
    # steps...not sure how to address this.
    # > koopa_add_rpath_to_ldflags "${dict['libluv']}/lib"
    cmake_args=(
        # > "-DCMAKE_CXX_FLAGS=${CPPFLAGS:-}"
        # > '-DUSE_BUNDLED=OFF'
        '-DCMAKE_BUILD_TYPE=Release'
        "-DCMAKE_C_FLAGS=${CFLAGS:-}"
        "-DCMAKE_EXE_LINKER_FLAGS=${LDFLAGS:-}"
        "-DCMAKE_INSTALL_PREFIX=${dict['prefix']}"
        "-DCMAKE_MODULE_LINKER_FLAGS=${LDFLAGS:-}"
        "-DCMAKE_SHARED_LINKER_FLAGS=${LDFLAGS:-}"
        '-DENABLE_LIBICONV=ON'
        '-DENABLE_LIBINTL=ON'
        '-DENABLE_LTO=ON'
        '-DPREFER_LUA=OFF'
        '-DHOMEBREW_PROG='
        "-DICONV_INCLUDE_DIR=${dict['libiconv']}/include"
        "-DICONV_LIBRARY=${dict['libiconv']}/lib/\
libiconv.${dict['shared_ext']}"
        "-DLibIntl_INCLUDE_DIR=${dict['gettext']}/include"
        "-DLibIntl_LIBRARY=${dict['gettext']}/lib/libintl.${dict['shared_ext']}"
        "-DLIBLUV_INCLUDE_DIR=${dict['libluv']}/include"
        "-DLIBLUV_LIBRARY=${dict['libluv']}/lib/libluv.${dict['shared_ext']}"
        "-DLIBTERMKEY_INCLUDE_DIR=${dict['libtermkey']}/include"
        "-DLIBTERMKEY_LIBRARY=${dict['libtermkey']}/lib/\
libtermkey.${dict['shared_ext']}"
        "-DLIBUV_INCLUDE_DIR=${dict['libuv']}/include"
        "-DLIBUV_LIBRARY=${dict['libuv']}/lib/libuv.${dict['shared_ext']}"
        "-DLIBVTERM_INCLUDE_DIR=${dict['libvterm']}/include"
        "-DLIBVTERM_LIBRARY=${dict['libvterm']}/lib/\
libvterm.${dict['shared_ext']}"
        "-DLUA_PRG=${app['luajit']}"
        "-DLUAJIT_INCLUDE_DIR=${dict['luajit']}/include/\
luajit-${dict['luajit_maj_min_ver']}"
        "-DLUAJIT_LIBRARY=${dict['luajit']}/lib/\
libluajit.${dict['shared_ext']}"
        "-DMSGPACK_INCLUDE_DIR=${dict['msgpack']}/include"
        "-DMSGPACK_LIBRARY=${dict['msgpack']}/lib/\
libmsgpackc.${dict['shared_ext']}"
        "-DTreeSitter_INCLUDE_DIR=${dict['tree_sitter']}/include"
        "-DTreeSitter_LIBRARY=${dict['tree_sitter']}/lib/\
libtree-sitter.${dict['shared_ext']}"
        "-DUNIBILIUM_INCLUDE_DIR=${dict['unibilium']}/include"
        "-DUNIBILIUM_LIBRARY=${dict['unibilium']}/lib/\
libunibilium.${dict['shared_ext']}"
    )
    dict['file']="v${dict['version']}.tar.gz"
    dict['url']="https://github.com/${dict['name']}/${dict['name']}/\
archive/${dict['file']}"
    koopa_download "${dict['url']}" "${dict['file']}"
    koopa_extract "${dict['file']}"
    koopa_cd "${dict['name']}-${dict['version']}"
    "${app['cmake']}" -LH -S . -B 'build' "${cmake_args[@]}"
    "${app['cmake']}" \
        --build 'build' \
        "-DCMAKE_C_FLAGS=${CFLAGS:-}" \
        "-DCMAKE_EXE_LINKER_FLAGS=${LDFLAGS:-}" \
        "-DCMAKE_MODULE_LINKER_FLAGS=${LDFLAGS:-}" \
        "-DCMAKE_SHARED_LINKER_FLAGS=${LDFLAGS:-}"
    "${app['cmake']}" --install 'build' \
        "-DCMAKE_C_FLAGS=${CFLAGS:-}" \
        "-DCMAKE_EXE_LINKER_FLAGS=${LDFLAGS:-}" \
        "-DCMAKE_MODULE_LINKER_FLAGS=${LDFLAGS:-}" \
        "-DCMAKE_SHARED_LINKER_FLAGS=${LDFLAGS:-}"
    return 0
}
