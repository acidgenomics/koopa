#!/usr/bin/env bash

# FIXME Rework as app.

koopa_locate_gs() {
    koopa_locate_conda_app \
        --app-name='gs' \
        --env-name='ghostscript'
}
