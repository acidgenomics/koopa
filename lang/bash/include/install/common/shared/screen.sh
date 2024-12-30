#!/usr/bin/env bash

main() {
    # """
    # Install screen.
    # @note Updated 2023-10-19.
    #
    # Currently fails to build on macOS using system clang.
    #
    # @seealso
    # - https://github.com/conda-forge/screen-feedstock
    # - https://formulae.brew.sh/formula/screen
    # - https://ports.macports.org/port/screen/
    # """
    local -A dict
    local -a build_deps conf_args deps
    build_deps=('autoconf' 'automake')
    deps=('libxcrypt' 'ncurses')
    koopa_activate_app --build-only "${build_deps[@]}"
    koopa_activate_app "${deps[@]}"
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    dict['url']="$(koopa_gnu_mirror_url)/screen/\
screen-${dict['version']}.tar.gz"
    koopa_download "${dict['url']}"
    koopa_extract "$(koopa_basename "${dict['url']}")" 'src'
    koopa_cd 'src'
    conf_args+=(
        "--prefix=${dict['prefix']}"
    )
    ./autogen.sh
    koopa_make_build "${conf_args[@]}"
    return 0
}
