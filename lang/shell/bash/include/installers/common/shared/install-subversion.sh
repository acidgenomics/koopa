#!/usr/bin/env bash

# FIXME Looks like we need to harden links on Linux:
# - apr
# - apr-util
# - sqlite

main() { # {{{1
    # """
    # Install Subversion.
    # @note Updated 2022-04-09.
    #
    # Requires Apache Portable Runtime (APR) library and Apache Portable Runtime
    # Utility (APRUTIL) library.
    #
    # @seealso
    # - https://svn.apache.org/repos/asf/subversion/trunk/INSTALL
    # - https://subversion.apache.org/download.cgi
    # - https://subversion.apache.org/source-code.html
    # - Need to use serf to support HTTPS URLs.
    #   https://serverfault.com/questions/522646/
    # """
    local app conf_args dict
    koopa_assert_has_no_args "$#"
    koopa_activate_opt_prefix \
        'apr' \
        'apr-util' \
        'perl' \
        'python' \
        'ruby' \
        'serf' \
        'sqlite'
    declare -A app=(
        [make]="$(koopa_locate_make)"
    )
    declare -A dict=(
        # > [mirror]='https://mirrors.ocf.berkeley.edu/apache'
        [mirror]='https://archive.apache.org/dist'
        [jobs]="$(koopa_cpu_count)"
        [name]='subversion'
        [opt_prefix]="$(koopa_opt_prefix)"
        [prefix]="${INSTALL_PREFIX:?}"
        [version]="${INSTALL_VERSION:?}"
    )
    conf_args=(
        "--prefix=${dict[prefix]}"
        '--disable-debug'
        '--disable-mod-activation'
        '--disable-plaintext-password-storage'
        '--enable-optimize'
        "--with-apr=${dict[opt_prefix]}/apr"
        "--with-apr-util=${dict[opt_prefix]}/apr-util"
        '--with-apxs=no'
        '--with-lz4=internal'
        "--with-serf=${dict[opt_prefix]}/serf" # HTTPS
        "--with-sqlite=${dict[opt_prefix]}/sqlite"
        '--with-utf8proc=internal'
        '--without-apache-libexecdir'
        '--without-berkeley-db'
        '--without-gpg-agent'
        '--without-jikes'
    )
    dict[file]="${dict[name]}-${dict[version]}.tar.bz2"
    dict[url]="${dict[mirror]}/${dict[name]}/${dict[file]}"
    koopa_download "${dict[url]}" "${dict[file]}"
    koopa_extract "${dict[file]}"
    koopa_cd "${dict[name]}-${dict[version]}"
    ./configure "${conf_args[@]}"
    "${app[make]}" --jobs="${dict[jobs]}"
    "${app[make]}" install
    return 0
}
