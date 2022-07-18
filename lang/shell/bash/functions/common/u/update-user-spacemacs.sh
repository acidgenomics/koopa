#!/usr/bin/env bash

koopa_update_user_spacemacs() {
    koopa_update_app \
        --name='spacemacs' \
        --prefix="$(koopa_spacemacs_prefix)" \
        --user \
        "$@"
}
