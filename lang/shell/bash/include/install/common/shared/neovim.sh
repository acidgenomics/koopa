#!/usr/bin/env bash

# FIXME Need to add support for these:
# - libtermkey
# - libvterm
# - unibilium
# - libnsl (linux)

# FIXME Need to add support for:
# UNIBILIUM_INCLUDE_DIR=<not found>
# UNIBILIUM_LIBRARY=<not found>

# FIXME Need to specify LIBINTL to our gettext?
# FIXME Need to specify LIBICONV to our libiconv

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
    )
    koopa_activate_opt_prefix "${deps[@]}"
    declare -A app=(
        ['cmake']="$(koopa_locate_cmake)"
    )
    [[ -x "${app['cmake']}" ]] || return 1
    declare -A dict=(
        ['jobs']="$(koopa_cpu_count)"
        ['libluv']="$(koopa_app_prefix 'libluv')"
        ['libuv']="$(koopa_app_prefix 'libuv')"
        ['lua']="$(koopa_app_prefix 'lua')"
        ['luajit']="$(koopa_app_prefix 'luajit')"
        ['msgpack']="$(koopa_app_prefix 'msgpack')"
        ['name']='neovim'
        ['prefix']="${KOOPA_INSTALL_PREFIX:?}"
        ['shared_ext']="$(koopa_shared_ext)"
        ['tree_sitter']="$(koopa_app_prefix 'tree-sitter')"
        ['version']="${KOOPA_INSTALL_VERSION:?}"
    )
    koopa_assert_is_dir \
        "${dict['libluv']}" \
        "${dict['libuv']}" \
        "${dict['lua']}" \
        "${dict['luajit']}" \
        "${dict['msgpack']}" \
        "${dict['tree_sitter']}"
    dict['file']="v${dict['version']}.tar.gz"
    dict['url']="https://github.com/${dict['name']}/${dict['name']}/\
archive/${dict['file']}"
    koopa_download "${dict['url']}" "${dict['file']}"
    koopa_extract "${dict['file']}"
    koopa_cd "${dict['name']}-${dict['version']}"
    # Lua no longer builds with pkg-config support by default.
    CFLAGS="-I${dict['lua']}/include ${CFLAGS:-}"
    export CFLAGS
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
        "-DLIBLUV_INCLUDE_DIR=${dict['libluv']}/include"
        "-DLIBLUV_LIBRARY=${dict['libluv']}/lib/libluv.${dict['shared_ext']}"
        "-DLIBUV_INCLUDE_DIR=${dict['libuv']}/include"
        "-DLIBUV_LIBRARY=${dict['libuv']}/lib/libuv.${dict['shared_ext']}"
        "-DLUAJIT_INCLUDE_DIR=${dict['luajit']}/include"
        "-DLUAJIT_LIBRARY=${dict['luajit']}/lib/\
libluajit.${dict['shared_ext']}"
        "-DMSGPACK_INCLUDE_DIR=${dict['msgpack']}/include"
        "-DMSGPACK_LIBRARY=${dict['msgpack']}/lib/\
libmsgpackc.${dict['shared_ext']}"
        "-DTreeSitter_INCLUDE_DIR=${dict['tree_sitter']}/include"
        "-DTreeSitter_LIBRARY=${dict['tree_sitter']}/lib/\
libtree-sitter.${dict['shared_ext']}"
    )
    "${app['cmake']}" -LH -S . -B 'build' "${cmake_args[@]}"
    "${app['cmake']}" --build 'build'
    "${app['cmake']}" --install 'build'
    return 0
}
