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
    build_deps+=('libtool' 'make' 'pkg-config')
    koopa_activate_app --build-only "${build_deps[@]}"
    app['libtool']="$(koopa_locate_libtool)"
    app['make']="$(koopa_locate_make)"
    koopa_assert_is_executable "${app[@]}"
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    dict['url']="https://github.com/neovim/unibilium/archive/\
v${dict['version']}.tar.gz"
    koopa_download "${dict['url']}"
    koopa_extract "$(koopa_basename "${dict['url']}")" 'src'
    koopa_cd 'src'
    koopa_print_env
    "${app['make']}" \
        LIBTOOL="${app['libtool']}" \
        PREFIX="${dict['prefix']}"
    "${app['make']}" install \
        LIBTOOL="${app['libtool']}" \
        PREFIX="${dict['prefix']}"
    return 0
}
