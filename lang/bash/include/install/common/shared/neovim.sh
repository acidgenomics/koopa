#!/usr/bin/env bash

main() {
    # """
    # Install Neovim.
    # @note Updated 2023-09-01.
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
    # - https://github.com/neovim/neovim/blob/master/runtime/CMakeLists.txt
    # - https://cmake.org/cmake/help/latest/variable/CMAKE_INSTALL_RPATH.html
    # """
    local -A app cmake dict
    local -a build_deps cmake_args deps local_mk_lines
    build_deps=(
        'make'
        'cmake'
        'libtool'
        'ninja'
        'pkg-config'
    )
    deps=(
        'm4'
        'zlib'
        'gettext'
        'libiconv'
        'ncurses'
        'python3.12'
    )
    koopa_activate_app --build-only "${build_deps[@]}"
    koopa_activate_app "${deps[@]}"
    app['make']="$(koopa_locate_make)"
    koopa_assert_is_executable "${app[@]}"
    dict['gettext']="$(koopa_app_prefix 'gettext')"
    dict['jobs']="$(koopa_cpu_count)"
    koopa_is_linux && dict['jobs']=1
    dict['libiconv']="$(koopa_app_prefix 'libiconv')"
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['shared_ext']="$(koopa_shared_ext)"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    dict['zlib']="$(koopa_app_prefix 'zlib')"
    cmake['iconv_include_dir']="${dict['libiconv']}/include"
    cmake['iconv_library']="${dict['libiconv']}/lib/\
libiconv.${dict['shared_ext']}"
    cmake['libintl_include_dir']="${dict['gettext']}/include"
    cmake['libintl_library']="${dict['gettext']}/lib/\
libintl.${dict['shared_ext']}"
    cmake['zlib_include_dir']="${dict['zlib']}/include"
    cmake['zlib_library']="${dict['zlib']}/lib/libz.${dict['shared_ext']}"
    koopa_assert_is_dir \
        "${cmake['iconv_include_dir']}" \
        "${cmake['libintl_include_dir']}" \
        "${cmake['zlib_include_dir']}"
    koopa_assert_is_file \
        "${cmake['iconv_library']}" \
        "${cmake['libintl_library']}" \
        "${cmake['zlib_library']}"
    readarray -t cmake_args <<< "$( \
        koopa_cmake_std_args --prefix="${dict['prefix']}" \
    )"
    cmake_args+=(
        "-DICONV_INCLUDE_DIR=${cmake['iconv_include_dir']}"
        "-DICONV_LIBRARY=${cmake['iconv_library']}"
        "-DLIBINTL_INCLUDE_DIR=${cmake['libintl_include_dir']}"
        "-DLIBINTL_LIBRARY=${cmake['libintl_library']}"
        "-DZLIB_INCLUDE_DIR=${cmake['zlib_include_dir']}"
        "-DZLIB_LIBRARY=${cmake['zlib_library']}"
    )
    local_mk_lines+=(
        'DEPS_CMAKE_FLAGS += -DUSE_BUNDLED=ON'
        'CMAKE_BUILD_TYPE := Release'
    )
    for arg in "${cmake_args[@]}"
    do
        case "$arg" in
            '-DCMAKE_BUILD_TYPE='*)
                continue
                ;;
        esac
        local_mk_lines+=("CMAKE_EXTRA_FLAGS += \"${arg}\"")
    done
    dict['local_mk']="$(koopa_print "${local_mk_lines[@]}")"
    dict['url']="https://github.com/neovim/neovim/archive/\
v${dict['version']}.tar.gz"
    koopa_download "${dict['url']}"
    koopa_extract "$(koopa_basename "${dict['url']}")" 'src'
    koopa_cd 'src'
    koopa_print_env
    koopa_print "${dict['local_mk']}"
    koopa_write_string --file='local.mk' --string="${dict['local_mk']}"
    "${app['make']}" VERBOSE=1 --jobs="${dict['jobs']}"
    "${app['make']}" install
    return 0
}
