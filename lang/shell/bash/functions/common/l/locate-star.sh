#!/usr/bin/env bash

# FIXME Rework as app.

koopa_locate_star() {
    koopa_locate_conda_app \
        --app-name='STAR' \
        --env-name='star'
}
