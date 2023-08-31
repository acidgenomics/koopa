#!/usr/bin/env bash

main() {
    # """
    # Install findutils.
    # @note Updated 2023-08-31.
    # """
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
        CFLAGS="${CFLAGS:-}"
        CFLAGS="-D__nonnull\(params\)= ${CFLAGS}"
        export CFLAGS
    fi
    koopa_install_gnu_app \
        --compress-ext='xz' \
        -D '--program-prefix=g'
    return 0
}
