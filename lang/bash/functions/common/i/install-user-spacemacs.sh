#!/usr/bin/env bash

koopa_install_user_spacemacs() {
    koopa_install_app \
        --name='spacemacs' \
        --prefix="$(koopa_spacemacs_prefix)" \
        --user \
        "$@"
}
