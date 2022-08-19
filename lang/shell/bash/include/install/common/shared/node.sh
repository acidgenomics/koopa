#!/usr/bin/env bash

# FIXME Cryptic yarn (node package) registry error when attempting to build
# coc.nvim dependencies in ~/.vim/plugged/coc.nvim:
# 
# # 'yarn registry error incorrect data check'
#
# This is likely due to some OpenSSL issue, so rebuild Node.js with better
# linkage, and see if that resolves.

main() {
    # """
    # Install Node.js.
    # @note Updated 2022-08-19.
    #
    # @seealso
    # - https://github.com/nodejs/node
    # - https://github.com/Homebrew/homebrew-core/blob/master/Formula/node.rb
    # """
    local app conf_args deps dict
    koopa_assert_has_no_args "$#"
    koopa_activate_build_opt_prefix 'pkg-config'
    deps=(
        'zlib'
        'icu4c'
        'libuv'
        'python'
        'openssl3'
        'c-ares'
        'brotli'
        'nghttp2'
        'ca-certificates'
    )
    koopa_activate_opt_prefix "${deps[@]}"
    declare -A app=(
        [make]="$(koopa_locate_make)"
        [python]="$(koopa_locate_python)"
    )
    [[ -x "${app[make]}" ]] || return 1
    [[ -x "${app[python]}" ]] || return 1
    app[python]="$(koopa_realpath "${app[python]}")"
    declare -A dict=(
        [ca_certificates]="$(koopa_app_prefix 'ca-certificates')"
        [brotli]="$(koopa_app_prefix 'brotli')"
        [cares]="$(koopa_app_prefix 'c-ares')"
        [jobs]="$(koopa_cpu_count)"
        [libuv]="$(koopa_app_prefix 'libuv')"
        [name]='node'
        [nghttp2]="$(koopa_app_prefix 'nghttp2')"
        [openssl]="$(koopa_app_prefix 'openssl3')"
        [prefix]="${INSTALL_PREFIX:?}"
        [version]="${INSTALL_VERSION:?}"
        [zlib]="$(koopa_app_prefix 'zlib')"
    )
    dict[cacerts]="${dict[ca_certificates]}/share/ca-certificates/cacert.pem"
    koopa_assert_is_file "${dict[cacerts]}"
    dict[file]="${dict[name]}-v${dict[version]}.tar.xz"
    dict[url]="https://nodejs.org/dist/v${dict[version]}/${dict[file]}"
    koopa_download "${dict[url]}" "${dict[file]}"
    koopa_extract "${dict[file]}"
    koopa_cd "${dict[name]}-v${dict[version]}"
    koopa_alert_coffee_time
    conf_args=(
        # > '--enable-lto'
        "--prefix=${dict[prefix]}"
        '--shared-brotli'
        "--shared-brotli-includes=${dict[brotli]}/include"
        "--shared-brotli-libpath=${dict[brotli]}/lib"
        '--shared-cares'
        "--shared-cares-includes=${dict[cares]}/include"
        "--shared-cares-libpath=${dict[cares]}/lib"
        '--shared-libuv'
        "--shared-libuv-includes=${dict[libuv]}/include"
        "--shared-libuv-libpath=${dict[libuv]}/lib"
        '--shared-nghttp2'
        "--shared-nghttp2-includes=${dict[nghttp2]}/include"
        "--shared-nghttp2-libpath=${dict[nghttp2]}/lib"
        '--shared-openssl'
        "--shared-openssl-includes=${dict[openssl]}/include"
        "--shared-openssl-libpath=${dict[openssl]}/lib"
        '--shared-zlib'
        "--shared-zlib-includes=${dict[zlib]}/include"
        "--shared-zlib-libpath=${dict[zlib]}/lib"
        '--with-intl=system-icu'
        '--without-corepack'
        "--openssl-system-ca-path=${dict[cacerts]}"
        '--openssl-use-def-ca-store'
        "PYTHON=${app[python]}"
    )
    ./configure --help
    ./configure "${conf_args[@]}"
    "${app[make]}" --jobs="${dict[jobs]}"
    # > "${app[make]}" test
    "${app[make]}" install
    return 0
}
