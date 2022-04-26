#!/usr/bin/env bash

main() { # {{{1
    # """
    # Install fribidi.
    # @note Updated 2022-04-20.
    #
    # @seealso
    # - https://github.com/fribidi/fribidi
    # - https://github.com/Homebrew/homebrew-core/blob/master/Formula/fribidi.rb
    # """
    local app conf_args dict
    declare -A app=(
        [make]="$(koopa_locate_make)"
    )
    declare -A dict=(
        [jobs]="$(koopa_cpu_count)"
        [name]='fribidi'
        [prefix]="${INSTALL_PREFIX:?}"
        [version]="${INSTALL_VERSION:?}"
    )
    dict[file]="${dict[name]}-${dict[version]}.tar.xz"
    dict[url]="https://github.com/${dict[name]}/${dict[name]}/releases/\
download/v${dict[version]}/${dict[file]}"
    koopa_download "${dict[url]}" "${dict[file]}"
    koopa_extract "${dict[file]}"
    koopa_cd "${dict[name]}-${dict[version]}"
    conf_args=(
        "--prefix=${dict[prefix]}"
        '--disable-debug'
        '--disable-dependency-tracking'
        '--disable-silent-rules'
        '--enable-static'
    )
    ./configure "${conf_args[@]}"
    "${app[make]}" --jobs="${dict[jobs]}"
    "${app[make]}" install
    return 0
}
