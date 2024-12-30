#!/usr/bin/env bash

# NOTE Consider switching to CMake build approach in future update.
# NOTE Add support for our ncurses in future update (TERMINFO_DIRS_DEFAULT).
# NOTE Latest 2.1.2 release isn't building successfully on macOS due to
# libtool configuration issues.

main() {
    # """
    # Install unibilium.
    # @note Updated 2024-09-23.
    #
    # @seealso
    # - https://formulae.brew.sh/formula/unibilium
    # - https://github.com/conda-forge/unibilium-feedstock
    # """
    local -A app dict
    local -a build_deps
    build_deps+=('pkg-config')
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    dict['url']="https://github.com/neovim/unibilium/archive/\
v${dict['version']}.tar.gz"
    koopa_download "${dict['url']}"
    koopa_extract "$(koopa_basename "${dict['url']}")" 'src'
    koopa_cd 'src'
    koopa_print_env
    koopa_cmake_build --prefix="${dict['prefix']}"
    return 0
}
