#!/usr/bin/env bash

main() {
    # """
    # Install cURL.
    # @note Updated 2024-09-10.
    #
    # The '--enable-versioned-symbols' avoids issue with curl installed in
    # both '/usr' and '/usr/local'.
    #
    # Alternatively, can use '--with-ca-path' instead of '--with-ca-bundle'.
    #
    # @seealso
    # - https://curl.haxx.se/docs/install.html
    # - https://curl.se/docs/sslcerts.html
    # - https://github.com/conda-forge/curl-feedstock
    # - https://github.com/Homebrew/homebrew-core/blob/master/Formula/curl.rb
    # - https://www.linuxfromscratch.org/blfs/view/svn/basicnet/curl.html
    # - https://stackoverflow.com/questions/30017397
    # """
    local -A dict
    local -a build_deps conf_args deps
    build_deps+=('pkg-config')
    deps+=(
        'ca-certificates'
        'zlib'
        'zstd'
        'openssl'
        'libssh2'
    )
    _koopa_activate_app --build-only "${build_deps[@]}"
    _koopa_activate_app "${deps[@]}"
    dict['ca_certificates']="$(_koopa_app_prefix 'ca-certificates')"
    dict['libssh2']="$(_koopa_app_prefix 'libssh2')"
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['ssl']="$(_koopa_app_prefix 'openssl')"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    dict['zlib']="$(_koopa_app_prefix 'zlib')"
    dict['zstd']="$(_koopa_app_prefix 'zstd')"
    dict['ca_bundle']="${dict['ca_certificates']}/share/ca-certificates/\
cacert.pem"
    _koopa_assert_is_file "${dict['ca_bundle']}"
    conf_args=(
        '--disable-debug'
        '--disable-dependency-tracking'
        '--disable-ldap'
        '--disable-silent-rules'
        '--disable-static'
        '--enable-threaded-resolver'
        '--enable-versioned-symbols'
        "--prefix=${dict['prefix']}"
        "--with-ca-bundle=${dict['ca_bundle']}"
        "--with-libssh2=${dict['libssh2']}"
        "--with-openssl=${dict['ssl']}"
        "--with-zlib=${dict['zlib']}"
        "--with-zstd=${dict['zstd']}"
        '--without-ca-path'
        '--without-gssapi'
        '--without-libidn2'
        '--without-libpsl'
        '--without-librtmp'
        '--without-nghttp2'
    )
    if _koopa_is_macos
    then
        conf_args+=(
            '--with-default-ssl-backend=openssl'
            '--with-secure-transport'
        )
    fi
    dict['version2']="${dict['version']//./_}"
    dict['url']="https://github.com/curl/curl/releases/download/\
curl-${dict['version2']}/curl-${dict['version']}.tar.xz"
    _koopa_download "${dict['url']}"
    _koopa_extract "$(_koopa_basename "${dict['url']}")" 'src'
    _koopa_cd 'src'
    _koopa_make_build "${conf_args[@]}"
    return 0
}
