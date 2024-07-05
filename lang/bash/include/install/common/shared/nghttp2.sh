#!/usr/bin/env bash

# NOTE Consider adding support for cunit here in a future update.

# NOTE This is failing to build on Ubuntu 22.
# Can confirm that this is specific to 22 and builds on 24 LTS (2024-06-27).

main() {
    # """
    # Install nghttp2.
    # @note Updated 2024-07-05.
    #
    # @seealso
    # - https://github.com/Homebrew/homebrew-core/blob/HEAD/Formula/nghttp2.rb
    # - https://github.com/Homebrew/homebrew-core/blob/HEAD/Formula/
    #     libnghttp2.rb
    # """
    local -A app dict
    local -a build_deps conf_args deps
    build_deps=(
        'pkg-config'
        'python3.12'
    )
    if koopa_is_linux
    then
        app['gcc']="$(koopa_locate_gcc --only-system)"
        dict['gcc_ver']="$(koopa_major_version "${app['gcc']}")"
        if [[ "${dict['gcc_ver']}" -lt 12 ]]
        then
            koopa_alert_note 'Unsupported system GCC detected.'
            build_deps+=('gcc')
            # FIXME Rework this
            # > export CC='/opt/koopa/opt/gcc/bin/gcc'
        fi
    fi
    deps=(
        'c-ares'
        'jemalloc'
        'libev'
        'icu4c' # libxml2
        'libxml2'
        'openssl3'
        'zlib'
    )
    koopa_activate_app --build-only "${build_deps[@]}"
    koopa_activate_app "${deps[@]}"
    app['python']="$(koopa_locate_python312 --realpath)"
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
