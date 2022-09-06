#!/usr/bin/env bash

main() {
    # """
    # Install man-db.
    # @note Updated 2022-08-25.
    #
    # Potentially useful:
    # > --program-prefix=g
    #
    # @seealso
    # - https://man-db.nongnu.org/development.html
    # - https://github.com/Homebrew/homebrew-core/blob/HEAD/Formula/man-db.rb
    # """
    local dict
    koopa_activate_opt_prefix \
        'groff' \
        'libpipeline' \
        'gdbm'
    declare -A dict=(
        ['prefix']="${INSTALL_PREFIX:?}"
    )
    koopa_install_app_passthrough \
        --installer='gnu-app' \
        --name='man-db' \
        -D '--disable-cache-owner' \
        -D '--disable-dependency-tracking' \
        -D '--disable-nls' \
        -D '--disable-setuid' \
        -D '--disable-silent-rules' \
        -D '--program-prefix=g' \
        -D "--with-config-file=${dict['prefix']}/etc/man_db.conf" \
        -D "--with-systemdsystemunitdir=${dict['prefix']}/etc/systemd/system" \
        -D "--with-systemdtmpfilesdir=${dict['prefix']}/etc/tmpfiles.d" \
        "$@"
}
