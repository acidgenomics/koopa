#!/usr/bin/env bash

main() {
    # """
    # Install Neovim.
    # @note Updated 2022-09-11.
    #
    # Homebrew is currently required for this to build on macOS.
    #
    # @seealso
    # - https://github.com/neovim/neovim/wiki/Building-Neovim
    # - https://github.com/neovim/neovim/wiki/Installing-Neovim
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
    local app deps dict local_mk
    koopa_assert_has_no_args "$#"
    koopa_activate_build_opt_prefix \
        'cmake' \
        'ninja' \
        'pkg-config'
    deps=(
        'm4'
        'zlib'
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
        ['luajit']="$(koopa_locate_luajit --realpath)"
        ['luarocks']="$(koopa_locate_luarocks --realpath)"
        ['make']="$(koopa_locate_make)"
    )
    [[ -x "${app['luajit']}" ]] || return 1
    [[ -x "${app['luarocks']}" ]] || return 1
    [[ -x "${app['make']}" ]] || return 1
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
        ['zlib']="$(koopa_app_prefix 'zlib')"
    )
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
    local rock rocks
    declare -A rocks=(
        ['lpeg']='1.0.2-1'
        ['mpack']='1.0.8'
    )
    for rock in "${!rocks[@]}"
    do
        "${app['luarocks']}" \
            --lua-dir="${dict['luajit']}" \
            install \
                --tree "${dict['libexec']}" \
                "$rock" "${rocks[$rock]}"
    done
    if koopa_is_macos
    then
        CFLAGS="$CFLAGS_BAK"
    fi
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
    local_mk=(
        'CMAKE_BUILD_TYPE := RelWithDebInfo'
        'DEPS_CMAKE_FLAGS += -DUSE_BUNDLED=OFF'
        'DEPS_CMAKE_FLAGS += -DUSE_BUNDLED_BUSTED=OFF'
        'DEPS_CMAKE_FLAGS += -DUSE_BUNDLED_GETTEXT=OFF'
        'DEPS_CMAKE_FLAGS += -DUSE_BUNDLED_LIBICONV=OFF'
        'DEPS_CMAKE_FLAGS += -DUSE_BUNDLED_LIBTERMKEY=OFF'
        'DEPS_CMAKE_FLAGS += -DUSE_BUNDLED_LIBUV=OFF'
        'DEPS_CMAKE_FLAGS += -DUSE_BUNDLED_LIBVTERM=OFF'
        'DEPS_CMAKE_FLAGS += -DUSE_BUNDLED_LUA=OFF'
        'DEPS_CMAKE_FLAGS += -DUSE_BUNDLED_LUAJIT=OFF'
        'DEPS_CMAKE_FLAGS += -DUSE_BUNDLED_LUAROCKS=OFF'
        'DEPS_CMAKE_FLAGS += -DUSE_BUNDLED_LUV=OFF' # FIXME ON
        'DEPS_CMAKE_FLAGS += -DUSE_BUNDLED_MSGPACK=OFF'
        'DEPS_CMAKE_FLAGS += -DUSE_BUNDLED_TS=OFF'
        'DEPS_CMAKE_FLAGS += -DUSE_BUNDLED_TS_PARSERS=OFF'
        'DEPS_CMAKE_FLAGS += -DUSE_BUNDLED_UNIBILIUM=OFF'
        'DEPS_CMAKE_FLAGS += -DUSE_BUNDLED_UTF8PROC=OFF'
        # > "CMAKE_EXTRA_FLAGS += \"-DCMAKE_CXX_FLAGS=${CPPFLAGS:-}\""
        "CMAKE_EXTRA_FLAGS += \"-DCMAKE_INSTALL_PREFIX=${dict['prefix']}"\"
        "CMAKE_EXTRA_FLAGS += \"-DCMAKE_C_FLAGS=${CFLAGS:-}\""
        "CMAKE_EXTRA_FLAGS += \"-DCMAKE_EXE_LINKER_FLAGS=${LDFLAGS:-}\""
        "CMAKE_EXTRA_FLAGS += \"-DCMAKE_MODULE_LINKER_FLAGS=${LDFLAGS:-}\""
        "CMAKE_EXTRA_FLAGS += \"-DCMAKE_SHARED_LINKER_FLAGS=${LDFLAGS:-}\""
        "CMAKE_EXTRA_FLAGS += \"-DICONV_INCLUDE_DIR=${dict['libiconv']}/include\""
        "CMAKE_EXTRA_FLAGS += \"-DICONV_LIBRARY=${dict['libiconv']}/lib/libiconv.${dict['shared_ext']}\""
        "CMAKE_EXTRA_FLAGS += \"-DLibIntl_INCLUDE_DIR=${dict['gettext']}/include\""
        "CMAKE_EXTRA_FLAGS += \"-DLibIntl_LIBRARY=${dict['gettext']}/lib/libintl.${dict['shared_ext']}\""
        "CMAKE_EXTRA_FLAGS += \"-DZLIB_INCLUDE_DIR=${dict['zlib']}/include\""
        "CMAKE_EXTRA_FLAGS += \"-DZLIB_LIBRARY=${dict['zlib']}/lib/libz.${dict['shared_ext']}\""
        "CMAKE_EXTRA_FLAGS += \"-DLIBLUV_INCLUDE_DIR=${dict['libluv']}/include\""
        "CMAKE_EXTRA_FLAGS += \"-DLIBLUV_LIBRARY=${dict['libluv']}/lib/libluv.${dict['shared_ext']}\""
        "CMAKE_EXTRA_FLAGS += \"-DLIBTERMKEY_INCLUDE_DIR=${dict['libtermkey']}/include\""
        "CMAKE_EXTRA_FLAGS += \"-DLIBTERMKEY_LIBRARY=${dict['libtermkey']}/lib/libtermkey.${dict['shared_ext']}\""
        "CMAKE_EXTRA_FLAGS += \"-DLIBUV_INCLUDE_DIR=${dict['libuv']}/include\""
        "CMAKE_EXTRA_FLAGS += \"-DLIBUV_LIBRARY=${dict['libuv']}/lib/libuv.${dict['shared_ext']}\""
        "CMAKE_EXTRA_FLAGS += \"-DLIBVTERM_INCLUDE_DIR=${dict['libvterm']}/include\""
        "CMAKE_EXTRA_FLAGS += \"-DLIBVTERM_LIBRARY=${dict['libvterm']}/lib/libvterm.${dict['shared_ext']}\""
        "CMAKE_EXTRA_FLAGS += \"-DLUA_PRG=${app['luajit']}\""
        "CMAKE_EXTRA_FLAGS += \"-DLUAJIT_INCLUDE_DIR=${dict['luajit']}/include/luajit-${dict['luajit_maj_min_ver']}\""
        "CMAKE_EXTRA_FLAGS += \"-DLUAJIT_LIBRARY=${dict['luajit']}/lib/libluajit.${dict['shared_ext']}\""
        "CMAKE_EXTRA_FLAGS += \"-DMSGPACK_INCLUDE_DIR=${dict['msgpack']}/include\""
        "CMAKE_EXTRA_FLAGS += \"-DMSGPACK_LIBRARY=${dict['msgpack']}/lib/libmsgpackc.${dict['shared_ext']}\""
        "CMAKE_EXTRA_FLAGS += \"-DTreeSitter_INCLUDE_DIR=${dict['tree_sitter']}/include\""
        "CMAKE_EXTRA_FLAGS += \"-DTreeSitter_LIBRARY=${dict['tree_sitter']}/lib/libtree-sitter.${dict['shared_ext']}\""
        "CMAKE_EXTRA_FLAGS += \"-DUNIBILIUM_INCLUDE_DIR=${dict['unibilium']}/include\""
        "CMAKE_EXTRA_FLAGS += \"-DUNIBILIUM_LIBRARY=${dict['unibilium']}/lib/libunibilium.${dict['shared_ext']}\""
    )
    dict['file']="v${dict['version']}.tar.gz"
    dict['url']="https://github.com/${dict['name']}/${dict['name']}/\
archive/${dict['file']}"
    koopa_download "${dict['url']}" "${dict['file']}"
    koopa_extract "${dict['file']}"
    koopa_cd "${dict['name']}-${dict['version']}"
    koopa_write_string \
        --file='local.mk' \
        --string="$(koopa_print "${local_mk[@]}")"
    # > "${app['make']}" distclean
    "${app['make']}" VERBOSE=1 --jobs="${dict['jobs']}"
    "${app['make']}" install
    return 0
}
