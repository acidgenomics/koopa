#!/usr/bin/env bash

main() { # {{{1
    # """
    # Install libxrandr.
    # @note Updated 2022-04-21.
    #
    # @seealso
    # - https://github.com/Homebrew/homebrew-core/blob/master/
    #     Formula/libxrandr.rb
    # """
    local app conf_args dict
    koopa_assert_has_no_args "$#"
    koopa_activate_opt_prefix \
        'libpthread-stubs' \
        'libx11' \
        'libxau' \
        'libxcb' \
        'libxdmcp' \
        'libxext' \
        'libxrender' \
        'pkg-config' \
        'xorgproto'
    declare -A app=(
        [make]="$(koopa_locate_make)"
    )
    declare -A dict=(
        [jobs]="$(koopa_cpu_count)"
        [name]='libXrandr'
        [prefix]="${INSTALL_PREFIX:?}"
        [version]="${INSTALL_VERSION:?}"
    )
    dict[file]="${dict[name]}-${dict[version]}.tar.bz2"
    dict[url]="https://www.x.org/archive/individual/lib/${dict[file]}"
    koopa_download "${dict[url]}" "${dict[file]}"
    koopa_extract "${dict[file]}"
    koopa_cd "${dict[name]}-${dict[version]}"
    conf_args=(
        "--prefix=${dict[prefix]}"
        '--disable-dependency-tracking'
        '--disable-silent-rules'
    )
    ./configure "${conf_args[@]}"
    "${app[make]}" --jobs="${dict[jobs]}"
    "${app[make]}" install
    return 0
}
