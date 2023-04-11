#!/usr/bin/env bash

main() {
    # """
    # Install oniguruma regular expressions library.
    # @note Updated 2023-04-11.
    #
    # @seealso
    # - https://github.com/Homebrew/homebrew-core/blob/master/
    #     Formula/oniguruma.rb
    # """
    local -A app dict
    local -a conf_args
    koopa_activate_app --build-only \
        'autoconf' \
        'automake' \
        'libtool' \
        'm4' \
        'pkg-config'
    app['autoreconf']="$(koopa_locate_autoreconf)"
    koopa_assert_is_executable "${app[@]}"
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    dict['version2']="$(koopa_major_minor_patch_version "${dict['version']}")"
    conf_args=(
        '--disable-dependency-tracking'
        '--disable-static'
        "--prefix=${dict['prefix']}"
    )
    dict['url']="https://github.com/kkos/oniguruma/releases/download/\
v${dict['version']}/onig-${dict['version']}.tar.gz"
    koopa_download "${dict['url']}"
    koopa_extract "$(koopa_basename "${dict['url']}")" 'src'
    koopa_cd 'src'
    "${app['autoreconf']}" -vfi
    koopa_make_build "${conf_args[@]}"
    return 0
}
