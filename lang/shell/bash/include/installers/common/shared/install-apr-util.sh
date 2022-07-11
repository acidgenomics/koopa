#!/usr/bin/env bash

# FIXME Need to resolve this on Linux:
# fatal error: expat.h: No such file or directory
#
#  uses_from_macos "expat"
#  uses_from_macos "libxcrypt"
#  uses_from_macos "sqlite"
#
#  on_linux do
#    depends_on "mawk"
#    depends_on "unixodbc"

main() {
    # """
    # Companion library to apr, the Apache Portable Runtime library.
    # @note Updated 2022-07-11.
    #
    # @seealso
    # - https://github.com/Homebrew/homebrew-core/blob/master/Formula/
    #     apr-util.rb
    # """
    local app conf_args dict
    koopa_assert_has_no_args "$#"
    koopa_activate_opt_prefix \
        'apr' \
        'expat' \
        'openssl3'
    declare -A app=(
        [make]="$(koopa_locate_make)"
    )
    declare -A dict=(
        [jobs]="$(koopa_cpu_count)"
        [name]='apr-util'
        [opt_prefix]="$(koopa_opt_prefix)"
        [prefix]="${INSTALL_PREFIX:?}"
        [version]="${INSTALL_VERSION:?}"
    )
    dict[file]="${dict[name]}-${dict[version]}.tar.bz2"
    dict[url]="https://archive.apache.org/dist/apr/${dict[file]}"
    koopa_download "${dict[url]}" "${dict[file]}"
    koopa_extract "${dict[file]}"
    koopa_cd "${dict[name]}-${dict[version]}"
    conf_args=(
        "--prefix=${dict[prefix]}"
        "--with-apr=${dict[opt_prefix]}/apr/bin/apr-1-config"
        '--with-crypto'
        "--with-openssl=${dict[opt_prefix]}/openssl3"
        '--without-pgsql'
    )
    ./configure "${conf_args[@]}"
    "${app[make]}" --jobs="${dict[jobs]}"
    "${app[make]}" install
    return 0
}
