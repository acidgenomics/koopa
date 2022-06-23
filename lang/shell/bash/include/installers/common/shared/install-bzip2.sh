#!/usr/bin/env bash

main() {
    # """
    # Install bzip2.
    # @note Updated 2022-06-14.
    #
    # @seealso
    # - https://www.sourceware.org/bzip2/
    # - https://github.com/Homebrew/homebrew-core/blob/master/Formula/bzip2.rb
    # """
    local app dict
    koopa_assert_has_no_args "$#"
    declare -A app=(
        [make]="$(koopa_locate_make)"
    )
    declare -A dict=(
        [jobs]="$(koopa_cpu_count)"
        [name]='bzip2'
        [prefix]="${INSTALL_PREFIX:?}"
        [version]="${INSTALL_VERSION:?}"
    )
    dict[file]="${dict[name]}-${dict[version]}.tar.gz"
    dict[url]="https://sourceware.org/pub/${dict[name]}/${dict[file]}"
    koopa_download "${dict[url]}" "${dict[file]}"
    koopa_extract "${dict[file]}"
    koopa_cd "${dict[name]}-${dict[version]}"
    "${app[make]}"
    # Build 'libbz2.so' shared library on Linux.
    if koopa_is_linux
    then
        "${app[make]}" -f 'Makefile-libbz2_so' 'clean'
        "${app[make]}" -f 'Makefile-libbz2_so'
    fi
    "${app[make]}" install "PREFIX=${dict[prefix]}"
    return 0
}
