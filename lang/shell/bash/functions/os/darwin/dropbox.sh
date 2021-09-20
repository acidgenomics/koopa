#!/usr/bin/env bash

koopa::macos_symlink_dropbox() { # {{{1
    # """
    # Symlink Dropbox.
    # @note Updated 2020-11-18.
    # """
    koopa::assert_is_admin
    koopa::rm --sudo "${HOME}/Desktop"
    koopa::ln "${HOME}/Dropbox/Desktop" "${HOME}/."
    koopa::rm --sudo "${HOME}/Documents"
    koopa::ln "${HOME}/Dropbox/Documents" "${HOME}/."
    sudo killAll 'Finder'
    return 0
}
