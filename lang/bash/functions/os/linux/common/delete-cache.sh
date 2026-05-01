#!/usr/bin/env bash

_koopa_linux_delete_cache() {
    # """
    # Delete Linux cache files.
    # @note Updated 2020-11-04.
    #
    # Don't clear '/var/log/' here, as this can mess with 'sshd'.
    # """
    _koopa_assert_has_no_args "$#"
    if ! _koopa_is_docker
    then
        _koopa_stop 'Cache removal only supported inside Docker images.'
    fi
    _koopa_alert 'Removing caches, logs, and temporary files.'
    _koopa_rm --sudo \
        '/root/.cache' \
        '/tmp/'* \
        '/var/backups/'* \
        '/var/cache/'*
    if _koopa_is_debian_like
    then
        _koopa_rm --sudo '/var/lib/apt/lists/'*
    fi
    return 0
}
