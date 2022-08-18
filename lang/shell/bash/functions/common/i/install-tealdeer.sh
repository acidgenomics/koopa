#!/usr/bin/env bash

koopa_install_tealdeer() {
    koopa_install_app \
        --link-in-bin='tldr' \
        --name='tealdeer' \
        "$@"
}
