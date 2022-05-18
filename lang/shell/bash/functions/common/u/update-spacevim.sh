#!/usr/bin/env bash

koopa_update_spacevim() {
    koopa_update_app \
        --name-fancy='SpaceVim' \
        --name='spacevim' \
        --prefix="$(koopa_spacevim_prefix)" \
        --user \
        "$@"
}
