#!/usr/bin/env bash

main() { # {{{1
    # """
    # Install libssh2.
    # @note Updated 2022-04-28.
    #
    # Including libz (zlib) with '--with-libz-prefix' runs into pkgconfig
    # issues with libgit2, since this doesn't link with '-lz' the way we'd
    # expect, like openssl. Disabled for the moment. Downstream, we run into
    # build issues in R installing gert, when zlib is included here.
    #
    # @seealso
    # - https://github.com/Homebrew/homebrew-core/blob/master/Formula/libssh2.rb
    # """
    local app conf_args dict
    koopa_assert_has_no_args "$#"
    koopa_activate_opt_prefix 'openssl'
    declare -A app=(
        [make]="$(koopa_locate_make)"
    )
    declare -A dict=(
        [jobs]="$(koopa_cpu_count)"
        [name]='libssh2'
        [opt_prefix]="$(koopa_opt_prefix)"
        [prefix]="${INSTALL_PREFIX:?}"
        [version]="${INSTALL_VERSION:?}"
    )
    dict[openssl]="$(koopa_realpath "${dict[opt_prefix]}/openssl")"
    dict[file]="${dict[name]}-${dict[version]}.tar.gz"
    dict[url]="https://www.libssh2.org/download/${dict[file]}"
    koopa_download "${dict[url]}" "${dict[file]}"
    koopa_extract "${dict[file]}"
    koopa_cd "${dict[name]}-${dict[version]}"
    conf_args=(
        "--prefix=${dict[prefix]}"
        '--disable-silent-rules'
        '--disable-examples-build'
        "--with-libssl-prefix=${dict[openssl]}"
        '--without-libz'
    )
    ./configure "${conf_args[@]}"
    "${app[make]}" --jobs="${dict[jobs]}"
    "${app[make]}" install
    return 0
}
