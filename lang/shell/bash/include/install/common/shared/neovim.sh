#!/usr/bin/env bash

# FIXME Now hitting this Lua package error:
#
# -- Checking Lua interpreter: /opt/koopa/app/lua/5.4.4/bin/lua
#/opt/koopa/app/lua/5.4.4/bin/lua: module 'lpeg' not found:
#	no field package.preload['lpeg']
#	no file '/usr/local/share/lua/5.4/lpeg.lua'
#	no file '/usr/local/share/lua/5.4/lpeg/init.lua'
#	no file '/usr/local/lib/lua/5.4/lpeg.lua'
#	no file '/usr/local/lib/lua/5.4/lpeg/init.lua'
#	no file './lpeg.lua'
#	no file './lpeg/init.lua'
#	no file '/usr/local/lib/lua/5.4/lpeg.so'
#	no file '/usr/local/lib/lua/5.4/loadall.so'
#	no file './lpeg.so'
#stack traceback:
#	[C]: in function 'require'
#	[C]: in ?
#-- [/opt/koopa/app/lua/5.4.4/bin/lua] The 'lpeg' lua package is required for building Neovim
#CMake Error at CMakeLists.txt:576 (message):
#  Failed to find a Lua 5.1-compatible interpreter

main() {
    # """
    # Install Neovim.
    # @note Updated 2022-09-09.
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
    # - https://www.leonerd.org.uk/code/libvterm/
    # """
    local app cmake_args deps dict
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
        'libluv'
        'lua'
        'luajit'
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
    )
    [[ -x "${app['cmake']}" ]] || return 1
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
    dict['file']="v${dict['version']}.tar.gz"
    dict['url']="https://github.com/${dict['name']}/${dict['name']}/\
archive/${dict['file']}"
    koopa_download "${dict['url']}" "${dict['file']}"
    koopa_extract "${dict['file']}"
    koopa_cd "${dict['name']}-${dict['version']}"
    cmake_args=(
        '-DCMAKE_BUILD_TYPE=Release'
        "-DCMAKE_CXX_FLAGS=${CPPFLAGS:-}"
        "-DCMAKE_C_FLAGS=${CFLAGS:-}"
        "-DCMAKE_EXE_LINKER_FLAGS=${LDFLAGS:-}"
        "-DCMAKE_INSTALL_PREFIX=${dict['prefix']}"
        "-DCMAKE_MODULE_LINKER_FLAGS=${LDFLAGS:-}"
        "-DCMAKE_SHARED_LINKER_FLAGS=${LDFLAGS:-}"
        '-DENABLE_LIBICONV=ON'
        '-DENABLE_LIBINTL=ON'
        '-DENABLE_LTO=ON'
        # Prefer LuaJIT instead of Lua.
        '-DPREFER_LUA=OFF'
        "-DICONV_INCLUDE_DIRS=${dict['libiconv']}/include"
        "-DICONV_LIBRARIES=${dict['libiconv']}/lib/\
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
        "-DLUAJIT_INCLUDE_DIR=${dict['luajit']}/include"
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
    "${app['cmake']}" -LH -S . -B 'build' "${cmake_args[@]}"
    "${app['cmake']}" --build 'build'
    "${app['cmake']}" --install 'build'
    return 0
}
