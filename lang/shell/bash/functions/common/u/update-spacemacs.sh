#!/usr/bin/env bash

koopa_update_spacemacs() {
    koopa_update_app \
        --name-fancy='Spacemacs' \
        --name='spacemacs' \
        --prefix="$(koopa_spacemacs_prefix)" \
        --user \
        "$@"
}
