#!/usr/bin/env bash

# NOTE Consider adding support for cunit here in a future update.

main() {
    # """
    # Install nghttp2.
    # @note Updated 2022-08-19.
    #
    # @seealso
    # - https://github.com/Homebrew/homebrew-core/blob/HEAD/Formula/nghttp2.rb
    # - https://github.com/Homebrew/homebrew-core/blob/HEAD/Formula/
    #     libnghttp2.rb
    # """
    local app conf_args deps dict
    koopa_assert_has_no_args "$#"
    koopa_activate_build_opt_prefix 'pkg-config'
    deps=(
        'c-ares'
        'jemalloc'
        'libev'
        'libxml2'
        'openssl3'
        'zlib'
        'boost'
        'python'
    )
    koopa_activate_opt_prefix "${deps[@]}"
    declare -A app=(
        ['make']="$(koopa_locate_make)"
        ['python']="$(koopa_locate_python)"
    )
    [[ -x "${app['make']}" ]] || return 1
    [[ -x "${app['python']}" ]] || return 1
    app['python']="$(koopa_realpath "${app['python']}")"
    declare -A dict=(
        ['boost']="$(koopa_app_prefix 'boost')"
        ['jobs']="$(koopa_cpu_count)"
        ['name']='nghttp2'
        ['prefix']="${KOOPA_INSTALL_PREFIX:?}"
        ['version']="${KOOPA_INSTALL_VERSION:?}"
    )
    dict['file']="${dict['name']}-${dict['version']}.tar.gz"
    dict['url']="https://github.com/${dict['name']}/${dict['name']}/releases/\
download/v${dict['version']}/${dict['file']}"
    koopa_download "${dict['url']}" "${dict['file']}"
    koopa_extract "${dict['file']}"
    koopa_cd "${dict['name']}-${dict['version']}"
    conf_args=(
        # > '--disable-python-bindings'
        "--prefix=${dict['prefix']}"
        '--disable-silent-rules'
        '--enable-app'
        '--disable-examples'
        '--disable-hpack-tools'
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
    ./configure --help
    ./configure "${conf_args[@]}"
    "${app['make']}" --jobs="${dict['jobs']}"
    "${app['make']}" install
    return 0
}
