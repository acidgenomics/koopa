#!/usr/bin/env bash

koopa_uninstall_user_spacevim() {
    koopa_uninstall_app \
        --name='spacevim' \
        --prefix="$(koopa_spacevim_prefix)" \
        --user \
        "$@"
}
