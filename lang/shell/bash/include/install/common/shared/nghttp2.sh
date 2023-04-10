#!/usr/bin/env bash

# NOTE Consider adding support for cunit here in a future update.

main() {
    # """
    # Install nghttp2.
    # @note Updated 2023-04-06.
    #
    # @seealso
    # - https://github.com/Homebrew/homebrew-core/blob/HEAD/Formula/nghttp2.rb
    # - https://github.com/Homebrew/homebrew-core/blob/HEAD/Formula/
    #     libnghttp2.rb
    # """
    local -A app dict
    local -a conf_args deps
    koopa_activate_app --build-only \
        'make' \
        'pkg-config' \
        'python3.11'
    deps=(
        'c-ares'
        'jemalloc'
        'libev'
        'libxml2'
        'openssl3'
        'zlib'
        'boost'
    )
    koopa_activate_app "${deps[@]}"
    app['make']="$(koopa_locate_make)"
    app['python']="$(koopa_locate_python311 --realpath)"
    koopa_assert_is_executable "${app[@]}"
    dict['boost']="$(koopa_app_prefix 'boost')"
    dict['jobs']="$(koopa_cpu_count)"
    dict['name']='nghttp2'
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    dict['file']="${dict['name']}-${dict['version']}.tar.gz"
    dict['url']="https://github.com/${dict['name']}/${dict['name']}/releases/\
download/v${dict['version']}/${dict['file']}"
    koopa_download "${dict['url']}" "${dict['file']}"
    koopa_extract "${dict['file']}"
    koopa_cd "${dict['name']}-${dict['version']}"
    conf_args=(
        "--prefix=${dict['prefix']}"
        '--disable-examples'
        '--disable-hpack-tools'
        '--disable-python-bindings'
        '--disable-silent-rules'
        '--enable-app'
        "--with-boost=${dict['boost']}"
        '--with-jemalloc'
        '--with-libcares'
        '--with-libev'
        '--with-libxml2'
        '--with-openssl'
        '--with-zlib'
        '--without-systemd'
        "PYTHON=${app['python']}"
    )
    koopa_print_env
    koopa_dl 'configure args' "${conf_args[*]}"
    ./configure --help
    ./configure "${conf_args[@]}"
    "${app['make']}" VERBOSE=1 --jobs="${dict['jobs']}"
    "${app['make']}" install
    return 0
}
