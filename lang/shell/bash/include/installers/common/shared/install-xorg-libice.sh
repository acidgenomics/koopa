#!/usr/bin/env bash

main() { # {{{1
    # """
    # Install libice.
    # @note Updated 2022-04-26.
    #
    # @seealso
    # - https://github.com/Homebrew/homebrew-core/blob/master/Formula/libice.rb
    # """
    local app build_deps conf_args deps dict
    koopa_assert_has_no_args "$#"
    build_deps=('pkg-config')
    deps=(
        'xorg-xorgproto'
        'xorg-xtrans'
    )
    koopa_activate_build_opt_prefix "${build_deps[@]}"
    koopa_activate_opt_prefix "${deps[@]}"
    declare -A app=(
        [make]="$(koopa_locate_make)"
    )
    declare -A dict=(
        [jobs]="$(koopa_cpu_count)"
        [name]='libICE'
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
        '--enable-docs=no'
        '--enable-specs=no'
    )
    ./configure "${conf_args[@]}"
    "${app[make]}" --jobs="${dict[jobs]}"
    "${app[make]}" install
    return 0
}
