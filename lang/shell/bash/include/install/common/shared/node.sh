#!/usr/bin/env bash

# NOTE This currently takes a long time to install.

main() {
    # """
    # Install Node.js.
    # @note Updated 2022-08-19.
    #
    # @seealso
    # - https://github.com/nodejs/node
    # - https://github.com/Homebrew/homebrew-core/blob/master/Formula/node.rb
    # """
    local app conf_args dict
    koopa_assert_has_no_args "$#"
    koopa_activate_build_opt_prefix 'pkg-config'
    koopa_activate_opt_prefix \
        'zlib' \
        'icu4c' \
        'libuv' \
        'python' \
        'openssl3'
    declare -A app=(
        [make]="$(koopa_locate_make)"
        [python]="$(koopa_locate_python)"
    )
    [[ -x "${app[make]}" ]] || return 1
    [[ -x "${app[python]}" ]] || return 1
    app[python]="$(koopa_realpath "${app[python]}")"
    declare -A dict=(
        [jobs]="$(koopa_cpu_count)"
        [libuv]="$(koopa_app_prefix 'libuv')"
        [name]='node'
        [openssl]="$(koopa_app_prefix 'openssl3')"
        [prefix]="${INSTALL_PREFIX:?}"
        [version]="${INSTALL_VERSION:?}"
        [zlib]="$(koopa_app_prefix 'zlib')"
    )
    dict[file]="${dict[name]}-v${dict[version]}.tar.xz"
    dict[url]="https://nodejs.org/dist/v${dict[version]}/${dict[file]}"
    koopa_download "${dict[url]}" "${dict[file]}"
    koopa_extract "${dict[file]}"
    koopa_cd "${dict[name]}-v${dict[version]}"
    koopa_alert_coffee_time
    export PYTHON="${app[python]}"
    conf_args=(
        # Consider adding these in the future:
        # > "--openssl-system-ca-path=<CACERTS.PEM>"
        # > '--shared-brotli'
        # > "--shared-brotli-includes=<INCLUDE>"
        # > "--shared-brotli-libpath=<LIB>"
        # > '--shared-cares'
        # > "--shared-cares-includes=<INCLUDE>"
        # > "--shared-cares-libpath=<LIB>"
        # > '--shared-nghttp2'
        # > "--shared-nghttp2-includes=<INCLUDE>"
        # > "--shared-nghttp2-libpath=<LIB>"
        "--prefix=${dict[prefix]}"
        '--enable-lto'
        '--shared-libuv'
        "--shared-libuv-includes=${dict[libuv]}/include"
        "--shared-libuv-libpath=${dict[libuv]}/lib"
        '--shared-openssl'
        "--shared-openssl-includes=${dict[openssl]}/include"
        "--shared-openssl-libpath=${dict[openssl]}/lib"
        '--shared-zlib'
        "--shared-zlib-includes=${dict[zlib]}/include"
        "--shared-zlib-libpath=${dict[zlib]}/lib"
        '--with-intl=system-icu'
        '--without-corepack'
        '--openssl-use-def-ca-store'
    )
    ./configure --help
    ./configure "${conf_args[@]}"
    "${app[make]}" --jobs="${dict[jobs]}"
    # > "${app[make]}" test
    "${app[make]}" install
    return 0
}
