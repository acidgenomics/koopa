#!/usr/bin/env bash

koopa::macos_symlink_dropbox() {
    koopa::rm -S "${HOME}/Desktop"
    koopa::ln "${HOME}/Dropbox/Desktop" "${HOME}/."
    koopa::rm -S "${HOME}/Documents"
    koopa::ln "${HOME}/Dropbox/Documents" "${HOME}/."
    sudo killAll Finder
    return 0
}
