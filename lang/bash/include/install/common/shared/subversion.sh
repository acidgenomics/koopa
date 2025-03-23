#!/usr/bin/env bash

main() {
    # """
    # Install Subversion.
    # @note Updated 2023-04-11.
    #
    # Requires Apache Portable Runtime (APR) library and Apache Portable Runtime
    # Utility (APRUTIL) library.
    #
    # Including serf for HTTPS is useful for installing R-devel.
    #
    # @seealso
    # - https://svn.apache.org/repos/asf/subversion/trunk/INSTALL
    # - https://subversion.apache.org/download.cgi
    # - https://subversion.apache.org/source-code.html
    # - Need to use serf to support HTTPS URLs.
    #   https://serverfault.com/questions/522646/
    # - https://lists.apache.org/thread/3qbhp66woztkgzq8sx6vfb7cjn6mcl9y
    # """
    local -A dict
    local -a conf_args
    koopa_activate_app --build-only 'pkg-config'
    koopa_activate_app \
        'zlib' \
        'apr' \
        'apr-util' \
        'openssl3' \
        'perl' \
        'python3.12' \
        'ruby' \
        'serf' \
        'sqlite'
    dict['apr']="$(koopa_app_prefix 'apr')"
    dict['apr_util']="$(koopa_app_prefix 'apr-util')"
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['serf']="$(koopa_app_prefix 'serf')"
    dict['sqlite']="$(koopa_app_prefix 'sqlite')"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    conf_args=(
        '--disable-debug'
        '--disable-mod-activation'
        '--disable-plaintext-password-storage'
        '--disable-static'
        '--enable-optimize'
        "--prefix=${dict['prefix']}"
        "--with-apr=${dict['apr']}"
        "--with-apr-util=${dict['apr_util']}"
        '--with-apxs=no'
        '--with-lz4=internal'
        "--with-serf=${dict['serf']}" # HTTPS
        "--with-sqlite=${dict['sqlite']}"
        '--with-utf8proc=internal'
        '--without-apache-libexecdir'
        '--without-berkeley-db'
        '--without-gpg-agent'
        '--without-jikes'
    )
    dict['url']="https://archive.apache.org/dist/subversion/\
subversion-${dict['version']}.tar.bz2"
    koopa_download "${dict['url']}"
    koopa_extract "$(koopa_basename "${dict['url']}")" 'src'
    koopa_cd 'src'
    koopa_make_build "${conf_args[@]}"
    return 0
}
