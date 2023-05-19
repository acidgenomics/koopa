#!/usr/bin/env bash

koopa_install_user_doom_emacs() {
    koopa_install_app \
        --name='doom-emacs' \
        --prefix="$(koopa_doom_emacs_prefix)" \
        --user \
        "$@"
}
