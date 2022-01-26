#!/usr/bin/env bash

koopa::linux_delete_cache() { # {{{1
    # """
    # Delete Linux cache files.
    # @note Updated 2020-11-04.
    #
    # Don't clear '/var/log/' here, as this can mess with 'sshd'.
    # """
    koopa::assert_has_no_args "$#"
    if ! koopa::is_docker
    then
        koopa::stop 'Cache removal only supported inside Docker images.'
    fi
    koopa::alert 'Removing caches, logs, and temporary files.'
    koopa::rm --sudo \
        '/root/.cache' \
        '/tmp/'* \
        '/var/backups/'* \
        '/var/cache/'*
    if koopa::is_debian_like
    then
        koopa::rm --sudo '/var/lib/apt/lists/'*
    fi
    return 0
}
