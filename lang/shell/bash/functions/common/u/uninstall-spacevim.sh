#!/usr/bin/env bash

koopa_uninstall_spacevim() {
    koopa_uninstall_app \
        --name-fancy='SpaceVim' \
        --name='spacevim' \
        --prefix="$(koopa_spacevim_prefix)" \
        --user \
        "$@"
}
