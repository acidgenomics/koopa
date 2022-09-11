#!/usr/bin/env bash

# FIXME Need to address this issue:
#  Relevant CMake configuration variables:
#    LibIntl_INCLUDE_DIR=/Library/Frameworks/R.framework/Headers
#    LibIntl_LIBRARY=<not found>

main() {
    # """
    # Install Neovim.
    # @note Updated 2022-09-11.
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
    # - https://github.com/neovim/neovim/blob/master/contrib/local.mk.example
    # """
    local app cmake_args deps dict
    koopa_assert_has_no_args "$#"
    koopa_activate_build_opt_prefix \
        'autoconf' \
        'automake' \
        'cmake' \
        'libtool' \
        'ninja' \
        'pkg-config'
    deps=(
        'm4'
        'zlib'
        'gettext'
        # > 'luajit'
        # > 'luarocks'
        'ncurses'
        'python'
    )
    koopa_activate_opt_prefix "${deps[@]}"
    declare -A app=(
        ['make']="$(koopa_locate_make)"
    )
    [[ -x "${app['make']}" ]] || return 1
    declare -A dict=(
        ['gettext']="$(koopa_app_prefix 'gettext')"
        ['jobs']="$(koopa_cpu_count)"
        ['name']='neovim'
        ['prefix']="${KOOPA_INSTALL_PREFIX:?}"
        ['shared_ext']="$(koopa_shared_ext)"
        ['version']="${KOOPA_INSTALL_VERSION:?}"
        ['zlib']="$(koopa_app_prefix 'zlib')"
    )
    dict['file']="v${dict['version']}.tar.gz"
    dict['url']="https://github.com/${dict['name']}/${dict['name']}/archive/\
refs/tags/${dict['file']}"
    koopa_download "${dict['url']}" "${dict['file']}"
    koopa_extract "${dict['file']}"
    koopa_cd "${dict['name']}-${dict['version']}"
    # FIXME How to specify Python here?
    # FIXME What about specifying Perl here?
    cmake_args=(
        'CMAKE_BUILD_TYPE=RelWithDebInfo'
        "CMAKE_INSTALL_PREFIX=${dict['prefix']}"

        # FIXME I don't think these do anything argh...
        "CMAKE_CXX_FLAGS=${CPPFLAGS:-}"
        "CMAKE_C_FLAGS=${CFLAGS:-}"
        "CMAKE_EXE_LINKER_FLAGS=${LDFLAGS:-}"
        "CMAKE_INSTALL_PREFIX=${dict['prefix']}"
        "CMAKE_MODULE_LINKER_FLAGS=${LDFLAGS:-}"
        "CMAKE_SHARED_LINKER_FLAGS=${LDFLAGS:-}"
        "LibIntl_INCLUDE_DIR=${dict['gettext']}/include"
        "LibIntl_LIBRARY=${dict['gettext']}/lib/libintl.${dict['shared_ext']}"
        "ZLIB_INCLUDE_DIR=${dict['zlib']}/include"
        "ZLIB_LIBRARY=${dict['zlib']}/lib/libz.${dict['shared_ext']}"
    )


    # Configure 'local.mk' file.
    local mk
    mk=(
        
    )
    dict['string']="$(koopa_print "${lines[@]}")"
    koopa_write_string \
        --file='local.mk' \
        --string="$(koopa_print "${lines[@]}")"
    "${app['make']}" distclean
    "${app['make']}" \
        --jobs="${dict['jobs']}" \
        "${cmake_args[@]}"
    "${app['make']}" install
    return 0
}
