#!/usr/bin/env bash

main() {
    # """
    # Install aria2.
    # @note Updated 2023-12-05.
    #
    # @seealso
    # - https://github.com/axel-download-accelerator/axel
    # - https://formulae.brew.sh/formula/axel
    # """
    local -A dict
    local -a build_deps conf_args deps
    build_deps+=('gawk' 'pkg-config')
    deps+=('gettext' 'openssl3')
    koopa_activate_app --build-only "${build_deps[@]}"
    koopa_activate_app "${deps[@]}"
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    conf_args+=(
        '--disable-silent-rules'
        "--prefix=${dict['prefix']}"
    )
    dict['url']="https://github.com/axel-download-accelerator/axel/releases/\
download/v${dict['version']}/axel-${dict['version']}.tar.xz"
    koopa_download "${dict['url']}"
    koopa_extract "$(koopa_basename "${dict['url']}")" 'src'
    koopa_cd 'src'
    koopa_make_build "${conf_args[@]}"
    return 0
}
