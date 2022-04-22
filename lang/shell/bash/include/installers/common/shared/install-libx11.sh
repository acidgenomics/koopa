#!/usr/bin/env bash

# NOTE Consider adding support for 'xorg-macros'.

main() { # {{{1
    # """
    # Install libx11.
    # @note Updated 2022-04-21.
    #
    # @seealso
    # - https://github.com/Homebrew/homebrew-core/blob/master/Formula/libxcb.rb
    # """
    local app conf_args dict
    koopa_assert_has_no_args "$#"
    koopa_activate_opt_prefix \
        'libpthread-stubs' \
        'libxau' \
        'libxcb' \
        'libxdmcp' \
        'pkg-config' \
        'python' \
        'xorgproto' \
        'xtrans'
    declare -A app=(
        [make]="$(koopa_locate_make)"
    )
    declare -A dict=(
        [jobs]="$(koopa_cpu_count)"
        [name]='libX11'
        [prefix]="${INSTALL_PREFIX:?}"
        [version]="${INSTALL_VERSION:?}"
    )
    dict[file]="${dict[name]}-${dict[version]}.tar.gz"
    dict[url]="https://www.x.org/archive/individual/lib/${dict[file]}"
    koopa_download "${dict[url]}" "${dict[file]}"
    koopa_extract "${dict[file]}"
    koopa_cd "${dict[name]}-${dict[version]}"
    conf_args=(
        "--prefix=${dict[prefix]}"
        '--disable-dependency-tracking'
        '--disable-silent-rules'
        '--enable-unix-transport'
        '--enable-tcp-transport'
        '--enable-ipv6'
        '--enable-local-transport'
        '--enable-loadable-i18n'
        '--enable-xthreads'
        '--enable-specs=no'
    )
    ./configure "${conf_args[@]}"
    "${app[make]}" --jobs="${dict[jobs]}"
    "${app[make]}" install
    return 0
}
