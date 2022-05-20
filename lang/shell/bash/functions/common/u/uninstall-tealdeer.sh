#!/usr/bin/env bash

koopa_uninstall_tealdeer() {
    koopa_uninstall_app \
        --unlink-in-bin='tldr' \
        --name='tealdeer' \
        "$@"
}
