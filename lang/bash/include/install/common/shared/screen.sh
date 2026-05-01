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
    _koopa_activate_app --build-only "${build_deps[@]}"
    _koopa_activate_app "${deps[@]}"
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    dict['url']="$(_koopa_gnu_mirror_url)/screen/\
screen-${dict['version']}.tar.gz"
    _koopa_download "${dict['url']}"
    _koopa_extract "$(_koopa_basename "${dict['url']}")" 'src'
    _koopa_cd 'src'
    conf_args+=(
        "--prefix=${dict['prefix']}"
    )
    ./autogen.sh
    _koopa_make_build "${conf_args[@]}"
    return 0
}
