#!/usr/bin/env bash

main() { # {{{1
    # """
    # Install man-db.
    # @note Updated 2022-04-25.
    #
    # @seealso
    # - https://man-db.nongnu.org/development.html
    # - https://github.com/Homebrew/homebrew-core/blob/HEAD/Formula/man-db.rb
    # """
    local install_args
    install_args=(
        '--activate-opt=groff'
        '--activate-opt=libpipeline'
    )
    install_args+=(
        # > -D "--with-config-file=#{etc}/man_db.conf"
        # > -D "--with-systemdsystemunitdir=#{etc}/systemd/system"
        # > -D "--with-systemdtmpfilesdir=#{etc}/tmpfiles.d"
        # > -D '--program-prefix=g'
        -D '--disable-cache-owner'
        -D '--disable-dependency-tracking'
        -D '--disable-nls'
        -D '--disable-setuid'
        -D '--disable-silent-rules'
    )
    koopa_install_gnu_app \
        --name='man-db' \
        --no-link-in-opt \
        --no-prefix-check \
        --quiet \
        "${install_args[@]}" \
        "$@"
}
