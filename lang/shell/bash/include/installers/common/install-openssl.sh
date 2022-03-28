#!/usr/bin/env bash

# FIXME Now seeing this with install on Debian:
# ./openssl: error while loading shared libraries: libssl.so.3: cannot open
# shared object file: No such file or directory

install_openssl() { # {{{1
    # """
    # Install OpenSSL.
    # @note Updated 2022-01-03.
    #
    # @seealso
    # - https://github.com/Homebrew/homebrew-core/blob/HEAD/Formula/openssl@3.rb
    # """
    local app dict
    koopa_assert_has_no_args "$#"
    declare -A app=(
        [make]="$(koopa_locate_make)"
    )
    declare -A dict=(
        [jobs]="$(koopa_cpu_count)"
        [name]='openssl'
        [prefix]="${INSTALL_PREFIX:?}"
        [version]="${INSTALL_VERSION:?}"
    )
    dict[file]="${dict[name]}-${dict[version]}.tar.gz"
    dict[url]="https://www.openssl.org/source/${dict[file]}"
    koopa_download "${dict[url]}" "${dict[file]}"
    koopa_extract "${dict[file]}"
    koopa_cd "${dict[name]}-${dict[version]}"
    ./config \
        --prefix="${dict[prefix]}" \
        --openssldir="${dict[prefix]}" \
        shared
    "${app[make]}" --jobs="${dict[jobs]}"
    # > "${app[make]}" test
    "${app[make]}" install
    return 0
}
