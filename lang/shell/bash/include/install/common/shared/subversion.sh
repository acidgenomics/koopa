#!/usr/bin/env bash

# FIXME Something didn't link expat correctly in one of the upstream
# dependencies...how to deal with that?

main() {
    # """
    # Install Subversion.
    # @note Updated 2022-08-11.
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
    local app conf_args dict
    koopa_assert_has_no_args "$#"
    koopa_activate_opt_prefix \
        'zlib' \
        'apr' \
        'apr-util' \
        'openssl3' \
        'perl' \
        'python' \
        'ruby' \
        'serf' \
        'sqlite'
    declare -A app=(
        [make]="$(koopa_locate_make)"
    )
    [[ -x "${app['make']}" ]] || return 1
    declare -A dict=(
        # > [mirror]='https://mirrors.ocf.berkeley.edu/apache'
        [mirror]='https://archive.apache.org/dist'
        [jobs]="$(koopa_cpu_count)"
        [name]='subversion'
        [prefix]="${INSTALL_PREFIX:?}"
        [version]="${INSTALL_VERSION:?}"
    )
    # FIXME What about expat here?
    dict[apr]="$(koopa_app_prefix 'apr')"
    dict[apr_util]="$(koopa_app_prefix 'apr-util')"
    dict[serf]="$(koopa_app_prefix 'serf')"
    dict[sqlite]="$(koopa_app_prefix 'sqlite')"
    conf_args=(
        "--prefix=${dict['prefix']}"
        '--disable-debug'
        '--disable-mod-activation'
        '--disable-plaintext-password-storage'
        '--enable-optimize'
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
    dict[file]="${dict['name']}-${dict['version']}.tar.bz2"
    dict[url]="${dict['mirror']}/${dict['name']}/${dict['file']}"
    koopa_download "${dict['url']}" "${dict['file']}"
    koopa_extract "${dict['file']}"
    koopa_cd "${dict['name']}-${dict['version']}"
    ./configure --help
    ./configure "${conf_args[@]}"
    "${app['make']}" --jobs="${dict['jobs']}"
    "${app['make']}" install
    return 0
}
