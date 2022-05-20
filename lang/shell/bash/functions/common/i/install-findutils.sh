#!/usr/bin/env bash

koopa_install_findutils() {
    local install_args
    install_args=(
        '--installer=gnu-app'
        '--link-in-bin=bin/find'
        '--link-in-bin=bin/locate'
        '--link-in-bin=bin/updatedb'
        '--link-in-bin=bin/xargs'
        '--name=findutils'
    )
    if koopa_is_macos
    then
        # Workaround for build failures in 4.8.0.
        # See also:
        # - https://github.com/Homebrew/homebrew-core/blob/master/
        #     Formula/findutils.rb
        # - https://lists.gnu.org/archive/html/bug-findutils/2021-01/
        #     msg00050.html
        # - https://lists.gnu.org/archive/html/bug-findutils/2021-01/
        #     msg00051.html
        export CFLAGS='-D__nonnull\(params\)='
    fi
    koopa_install_app "${install_args[@]}" "$@"
}
