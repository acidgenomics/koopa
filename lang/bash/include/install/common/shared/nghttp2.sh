#!/usr/bin/env bash

# NOTE Consider adding support for cunit here in a future update.

main() {
    # """
    # Install nghttp2.
    # @note Updated 2025-08-21.
    #
    # @seealso
    # - https://github.com/Homebrew/homebrew-core/blob/HEAD/Formula/nghttp2.rb
    # - https://github.com/Homebrew/homebrew-core/blob/HEAD/Formula/
    #     libnghttp2.rb
    # """
    local -A app dict
    local -a build_deps conf_args deps
    build_deps=('pkg-config' 'python')
    # This fails to build with GCC 11 on Ubuntu 22, so requiring our GCC.
    koopa_is_linux && build_deps+=('gcc')
    deps=(
        'c-ares'
        'jemalloc'
        'libev'
        'icu4c' # libxml2
        'libxml2'
        'openssl'
        'zlib'
    )
    koopa_activate_app --build-only "${build_deps[@]}"
    koopa_activate_app "${deps[@]}"
    app['python']="$(koopa_locate_python --realpath)"
    koopa_assert_is_executable "${app[@]}"
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    conf_args=(
        '--disable-examples'
        '--disable-hpack-tools'
        '--disable-silent-rules'
        '--disable-static'
        '--enable-app'
        "--prefix=${dict['prefix']}"
        '--with-jemalloc'
        '--with-libcares'
        '--with-libev'
        '--with-libxml2'
        '--with-openssl'
        '--with-zlib'
        '--without-systemd'
        "PYTHON=${app['python']}"
    )
    dict['url']="https://github.com/nghttp2/nghttp2/releases/download/\
v${dict['version']}/nghttp2-${dict['version']}.tar.gz"
    koopa_download "${dict['url']}"
    koopa_extract "$(koopa_basename "${dict['url']}")" 'src'
    koopa_cd 'src'
    koopa_make_build "${conf_args[@]}"
    return 0
}
