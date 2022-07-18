#!/usr/bin/env bash

koopa_update_user_doom_emacs() {
    koopa_update_app \
        --name='doom-emacs' \
        --prefix="$(koopa_doom_emacs_prefix)" \
        --user \
        "$@"
}
