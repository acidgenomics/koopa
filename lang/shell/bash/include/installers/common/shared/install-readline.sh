#!/usr/bin/env bash

main() { # {{{1
    # """
    # Install readline.
    # @note Updated 2022-04-21.
    #
    # Check linkage on Linux with:
    # ldd -r /opt/koopa/opt/readline/lib/libreadline.so
    #
    # @seealso
    # - https://github.com/Homebrew/homebrew-core/blob/master/Formula/
    #     readline.rb
    # - https://stackoverflow.com/a/34723695/3911732
    # - https://github.com/archlinux/svntogit-packages/blob/master/readline/
    #     repos/core-x86_64/PKGBUILD
    # """
    local app conf_args dict
    koopa_assert_has_no_args "$#"
    koopa_activate_opt_prefix 'ncurses' 'pkg-config'
    declare -A app=(
        [make]="$(koopa_locate_make)"
    )
    declare -A dict=(
        [gnu_mirror]="$(koopa_gnu_mirror_url)"
        [jobs]="$(koopa_cpu_count)"
        [name]='readline'
        [opt_prefix]="$(koopa_opt_prefix)"
        [prefix]="${INSTALL_PREFIX:?}"
        [version]="${INSTALL_VERSION:?}"
    )
    dict[file]="${dict[name]}-${dict[version]}.tar.gz"
    dict[url]="${dict[gnu_mirror]}/${dict[name]}/${dict[file]}"
    koopa_download "${dict[url]}" "${dict[file]}"
    koopa_extract "${dict[file]}"
    koopa_cd "${dict[name]}-${dict[version]}"
    conf_args=(
        "--prefix=${dict[prefix]}"
        '--enable-shared'
        '--enable-static'
        '--with-curses'
    )
    export CFLAGS='-fPIC'
    ./configure "${conf_args[@]}"
    # Alternatively:
    # > SHLIB_LIBS="${dict[opt_prefix]}/ncurses/lib/libncurses.so"
    "${app[make]}" \
        --jobs="${dict[jobs]}" \
        SHLIB_LIBS='-lncurses'
    "${app[make]}" install
    if koopa_is_linux
    then
        app[ldd]="$(koopa_locate_ldd)"
        "${app[ldd]}" -r "${dict[prefix]}/lib/libreadline.so"
    fi
    return 0
}
