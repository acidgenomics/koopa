#!/usr/bin/env bash

main() { # {{{1
    # """
    # Install lzo.
    # @note Updated 2022-04-21.
    #
    # @seealso
    # - https://github.com/Homebrew/homebrew-core/blob/HEAD/Formula/lzo.rb
    # """
    local app conf_args dict
    koopa_assert_has_no_args "$#"
    declare -A app=(
        [make]="$(koopa_locate_make)"
    )
    declare -A dict=(
        [jobs]="$(koopa_cpu_count)"
        [name]='lzo'
        [prefix]="${INSTALL_PREFIX:?}"
        [version]="${INSTALL_VERSION:?}"
    )
    dict[file]="${dict[name]}-${dict[version]}.tar.gz"
    dict[url]="https://www.oberhumer.com/opensource/${dict[name]}/\
download/${dict[file]}"
    koopa_download "${dict[url]}" "${dict[file]}"
    koopa_extract "${dict[file]}"
    koopa_cd "${dict[name]}-${dict[version]}"
    conf_args=(
        "--prefix=${dict[prefix]}"
        '--disable-dependency-tracking'
        '--enable-shared'
    )
    ./configure "${conf_args[@]}"
    "${app[make]}" --jobs="${dict[jobs]}"
    # > "${app[make]}" check
    "${app[make]}" install
    return 0
}
