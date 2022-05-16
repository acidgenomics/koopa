#!/bin/sh

koopa_export_gnupg() {
    # """
    # Export GnuPG settings.
    # @note Updated 2022-04-08.
    #
    # Enable passphrase prompting in terminal.
    # Useful for getting Docker credential store to work.
    # https://github.com/docker/docker-credential-helpers/issues/118
    # """
    [ -z "${GPG_TTY:-}" ] || return 0
    koopa_is_tty || return 0
    GPG_TTY="$(tty || true)"
    [ -n "$GPG_TTY" ] || return 0
    export GPG_TTY
    return 0
}
