#!/usr/bin/env bash

koopa_uninstall_user_doom_emacs() {
    koopa_uninstall_app \
        --name='doom-emacs' \
        --prefix="$(koopa_doom_emacs_prefix)" \
        --user \
        "$@"
}
