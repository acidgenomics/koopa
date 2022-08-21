#!/usr/bin/env bash

main() {
    # """
    # Install cURL.
    # @note Updated 2022-08-16.
    #
    # The '--enable-versioned-symbols' avoids issue with curl installed in
    # both '/usr' and '/usr/local'.
    #
    # Alternatively, can use '--with-ca-path' instead of '--with-ca-bundle'.
    #
    # @seealso
    # - https://curl.haxx.se/docs/install.html
    # - https://curl.se/docs/sslcerts.html
    # - https://github.com/Homebrew/homebrew-core/blob/master/Formula/curl.rb
    # - https://stackoverflow.com/questions/30017397
    # """
    local app dict
    koopa_assert_has_no_args "$#"
    koopa_activate_build_opt_prefix 'pkg-config'
    koopa_activate_opt_prefix \
        'zlib' \
        'zstd' \
        'ca-certificates' \
        'openssl3'
    declare -A app=(
        [make]="$(koopa_locate_make)"
    )
    [[ -x "${app['make']}" ]] || return 1
    declare -A dict=(
        [ca_certificates]="$(koopa_app_prefix 'ca-certificates')"
        [jobs]="$(koopa_cpu_count)"
        [name]='curl'
        [prefix]="${INSTALL_PREFIX:?}"
        [ssl]="$(koopa_app_prefix 'openssl3')"
        [version]="${INSTALL_VERSION:?}"
        [zlib]="$(koopa_app_prefix 'zlib')"
        [zstd]="$(koopa_app_prefix 'zstd')"
    )
    dict['cacert']="${dict['ca_certificates']}/share/ca-certificates/cacert.pem"
    koopa_assert_is_file "${dict['cacert']}"
    dict['file']="${dict['name']}-${dict['version']}.tar.xz"
    dict['version2']="${dict['version']//./_}"
    dict['url']="https://github.com/${dict['name']}/${dict['name']}/releases/\
download/${dict['name']}-${dict['version2']}/${dict['file']}"
    koopa_download "${dict['url']}" "${dict['file']}"
    koopa_extract "${dict['file']}"
    koopa_cd "${dict['name']}-${dict['version']}"
    conf_args=(
        "--prefix=${dict['prefix']}"
        '--enable-versioned-symbols'
        "--with-ca-bundle=${dict['cacert']}"
        "--with-ssl=${dict['ssl']}"
        "--with-zlib=${dict['zlib']}"
        "--with-zstd=${dict['zstd']}"
        '--without-ca-path'
    )
    ./configure --help
    ./configure "${conf_args[@]}"
    "${app['make']}" --jobs="${dict['jobs']}"
    # > "${app['make']}" test
    "${app['make']}" install
    return 0
}
