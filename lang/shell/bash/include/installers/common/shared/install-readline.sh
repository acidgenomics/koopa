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
    local app dict
    koopa_assert_has_no_args "$#"
    declare -A dict=(
        [opt_prefix]="$(koopa_opt_prefix)"
        [prefix]="${INSTALL_PREFIX:?}"
    )
    if koopa_is_linux
    then
        export CFLAGS='-fPIC'
        # > export SHLIB_LIBS='-lncurses'
        export SHLIB_LIBS="${dict[opt_prefix]}/ncurses/lib/libncurses.so"
    fi
    koopa_install_gnu_app \
        --activate-opt='ncurses' \
        --name='readline' \
        --no-prefix-check \
        -D '--enable-shared' \
        -D '--enable-static' \
        -D '--with-curses' \
        "$@"
    if koopa_is_linux
    then
        declare -A app
        app[ldd]="$(koopa_locate_ldd)"
        "${app[ldd]}" -r "${dict[prefix]}/lib/libreadline.so"
    fi
    # FIXME On macOS, consider checking with otool -L...
    return 0
}
