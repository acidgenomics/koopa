#!/usr/bin/env bash

main() {
    # """
    # Install man-db.
    # @note Updated 2023-08-29.
    #
    # Potentially useful:
    # > --program-prefix=g
    #
    # @seealso
    # - https://man-db.nongnu.org/development.html
    # - https://github.com/Homebrew/homebrew-core/blob/HEAD/Formula/man-db.rb
    # """
    local -A dict
    local -a conf_args install_args
    local conf_arg
    koopa_activate_app --build-only 'pkg-config'
    koopa_activate_app \
        'groff' \
        'libpipeline' \
        'gdbm'
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    conf_args=(
        '--disable-cache-owner'
        '--disable-dependency-tracking'
        '--disable-nls'
        '--disable-setuid'
        '--disable-silent-rules'
        '--program-prefix=g'
        "--with-config-file=${dict['prefix']}/etc/man_db.conf"
        "--with-systemdsystemunitdir=${dict['prefix']}/etc/systemd/system"
        "--with-systemdtmpfilesdir=${dict['prefix']}/etc/tmpfiles.d"
    )
    for conf_arg in "${conf_args[@]}"
    do
        install_args+=('-D' "$conf_arg")
    done
    koopa_install_gnu_app --non-gnu-mirror "${install_args[@]}"
    return 0
}
