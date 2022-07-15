#!/usr/bin/env bash

koopa_update_doom_emacs() {
    koopa_update_app \
        --name-fancy='Doom Emacs' \
        --name='doom-emacs' \
        --prefix="$(koopa_doom_emacs_prefix)" \
        --user \
        "$@"
}
