#!/usr/bin/env bash

koopa_install_spacevim() {
    koopa_install_app \
        --name-fancy='SpaceVim' \
        --name='spacevim' \
        --prefix="$(koopa_spacevim_prefix)" \
        --user \
        "$@"
}
