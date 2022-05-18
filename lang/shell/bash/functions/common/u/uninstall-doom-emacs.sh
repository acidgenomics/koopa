#!/usr/bin/env bash

koopa_uninstall_doom_emacs() {
    koopa_uninstall_app \
        --name-fancy='Doom Emacs' \
        --name='doom-emacs' \
        --prefix="$(koopa_doom_emacs_prefix)" \
        --user \
        "$@"
}
