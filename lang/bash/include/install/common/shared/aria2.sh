#!/usr/bin/env bash

# NOTE May need to locate ca-certificates with '--with-ca-bundle'.

main() {
    # """
    # Install aria2.
    # @note Updated 2024-06-15.
    #
    # @seealso
    # - https://github.com/aria2/aria2
    # - https://formulae.brew.sh/formula/aria2
    # """
    local -A dict
    local -a build_deps conf_args deps
    build_deps+=('pkg-config')
    deps+=(
        'zlib'
        'gettext'
        'openssl'
        'libssh2'
        'icu4c' # libxml2
        'libxml2'
        'sqlite'
    )
    koopa_activate_app --build-only "${build_deps[@]}"
    koopa_activate_app "${deps[@]}"
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    conf_args+=(
        '--disable-bittorrent'
        '--disable-dependency-tracking'
        '--disable-metalink'
        "--prefix=${dict['prefix']}"
        '--with-libssh2'
        '--without-gnutls'
        '--without-libgcrypt'
        '--without-libgmp'
        '--without-libnettle'
    )
    if koopa_is_macos
    then
        conf_args+=(
            '--with-appletls'
            '--without-openssl'
        )
    else
        conf_args+=(
            '--with-openssl'
            '--without-appletls'
        )
    fi
    dict['url']="https://github.com/aria2/aria2/releases/download/\
release-${dict['version']}/aria2-${dict['version']}.tar.xz"
    koopa_download "${dict['url']}"
    koopa_extract "$(koopa_basename "${dict['url']}")" 'src'
    koopa_cd 'src'
    koopa_make_build "${conf_args[@]}"
    return 0
}
