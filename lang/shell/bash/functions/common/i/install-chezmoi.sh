#!/usr/bin/env bash

# FIXME This is informing about skipping 'chezmoi.1' man link.
# Need to rethink this approach.

koopa_install_chezmoi() {
    koopa_install_app \
        --link-in-bin='chezmoi' \
        --name='chezmoi' \
        "$@"
}
