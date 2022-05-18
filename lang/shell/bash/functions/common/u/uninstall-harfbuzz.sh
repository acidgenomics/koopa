#!/usr/bin/env bash

koopa_uninstall_harfbuzz() {
    koopa_uninstall_app \
        --name-fancy='HarfBuzz' \
        --name='harfbuzz' \
        "$@"
}
