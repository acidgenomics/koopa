#!/usr/bin/env bash

main() {
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
        CFLAGS="-D__nonnull\(params\)= ${CFLAGS:-}"
        export CFLAGS
    fi
    koopa_install_app_subshell \
        --installer='gnu-app' \
        --name='findutils' \
        -D '--program-prefix=g'
}
