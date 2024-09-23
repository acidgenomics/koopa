#!/usr/bin/env bash

# FIXME libtool config isn't working correct on macOS currently.

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
    local -a build_deps conf_args
    build_deps+=('autoconf' 'automake' 'libtool' 'pkg-config')
    koopa_activate_app --build-only "${build_deps[@]}"
    app['autoreconf']="$(koopa_locate_autoreconf)"
    app['libtool']="$(koopa_locate_libtool)"
    koopa_assert_is_executable "${app[@]}"
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    dict['url']="https://github.com/neovim/unibilium/archive/\
v${dict['version']}.tar.gz"
    conf_args+=(
        "--prefix=${dict['prefix']}"
        # > "LIBTOOL=${app['libtool']}"
    )
    koopa_download "${dict['url']}"
    koopa_extract "$(koopa_basename "${dict['url']}")" 'src'
    koopa_cd 'src'
    koopa_print_env
    "${app['autoreconf']}" --force --install --verbose
    koopa_make_build "${conf_args[@]}"
    return 0
}
