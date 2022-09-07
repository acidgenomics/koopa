#!/usr/bin/env bash

# FIXME Need to configure '/etc/shells' for shared install.
# FIXME Need to symlink Application Support on macOS (do this in dotfiles).

koopa_install_nushell() {
    koopa_install_app \
        --name='nushell' \
        "$@"
}
