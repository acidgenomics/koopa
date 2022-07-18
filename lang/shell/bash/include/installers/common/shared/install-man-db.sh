#!/usr/bin/env bash

main() {
    # """
    # Install man-db.
    # @note Updated 2022-07-14.
    #
    # Potentially useful:
    # > --program-prefix=g
    #
    # @seealso
    # - https://man-db.nongnu.org/development.html
    # - https://github.com/Homebrew/homebrew-core/blob/HEAD/Formula/man-db.rb
    # """
    local dict
    declare -A dict=(
        [prefix]="${INSTALL_PREFIX:?}"
    )
    koopa_install_app_internal \
        --activate-opt='groff' \
        --activate-opt='libpipeline' \
        --activate-opt='gdbm' \
        --installer='gnu-app' \
        --name='man-db' \
        -D '--disable-cache-owner' \
        -D '--disable-dependency-tracking' \
        -D '--disable-nls' \
        -D '--disable-setuid' \
        -D '--disable-silent-rules' \
        -D "--with-config-file=${dict[prefix]}/etc/man_db.conf" \
        -D "--with-systemdsystemunitdir=${dict[prefix]}/etc/systemd/system" \
        -D "--with-systemdtmpfilesdir=${dict[prefix]}/etc/tmpfiles.d" \
        "$@"
}
