#!/usr/bin/env bash

# NOTE Consider adding support for 'xorg-macros'.

main() { # {{{1
    # """
    # Install libxrender.
    # @note Updated 2022-04-26.
    #
    # @seealso
    # - https://github.com/Homebrew/homebrew-core/blob/master/
    #     Formula/libxrender.rb
    # """
    local app conf_args dict
    koopa_assert_has_no_args "$#"
    koopa_activate_build_opt_prefix 'pkg-config'
    koopa_activate_opt_prefix \
        'xorg-xorgproto' \
        'xorg-libpthread-stubs' \
        'xorg-libxau' \
        'xorg-libxdmcp' \
        'xorg-libxcb' \
        'xorg-libx11'
    declare -A app=(
        [make]="$(koopa_locate_make)"
    )
    declare -A dict=(
        [jobs]="$(koopa_cpu_count)"
        [name]='libXrender'
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
