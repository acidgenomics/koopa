#!/usr/bin/env bash

# FIXME Rework as app.

koopa_locate_efetch() {
    koopa_locate_conda_app \
        --app-name='efetch' \
        --env-name='entrez-direct'
}
