#!/usr/bin/env bash

koopa_install_man_db() {
    # """
    # @seealso
    # - https://man-db.nongnu.org/development.html
    # - https://github.com/Homebrew/homebrew-core/blob/HEAD/Formula/man-db.rb
    # """
    koopa_install_app \
        --activate-opt='groff' \
        --activate-opt='libpipeline' \
        --installer='gnu-app' \
        --link-in-bin='bin/man' \
        --name='man-db' \
        -D '--disable-cache-owner' \
        -D '--disable-dependency-tracking' \
        -D '--disable-nls' \
        -D '--disable-setuid' \
        -D '--disable-silent-rules' \
        "$@"
}
