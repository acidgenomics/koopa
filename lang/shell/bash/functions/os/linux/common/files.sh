#!/usr/bin/env bash

koopa_linux_delete_cache() { # {{{1
    # """
    # Delete Linux cache files.
    # @note Updated 2020-11-04.
    #
    # Don't clear '/var/log/' here, as this can mess with 'sshd'.
    # """
    koopa_assert_has_no_args "$#"
    if ! koopa_is_docker
    then
        koopa_stop 'Cache removal only supported inside Docker images.'
    fi
    koopa_alert 'Removing caches, logs, and temporary files.'
    koopa_rm --sudo \
        '/root/.cache' \
        '/tmp/'* \
        '/var/backups/'* \
        '/var/cache/'*
    if koopa_is_debian_like
    then
        koopa_rm --sudo '/var/lib/apt/lists/'*
    fi
    return 0
}
