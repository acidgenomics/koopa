#!/usr/bin/env bash

koopa_locate_efetch() {
    koopa_locate_conda_app \
        --app-name='efetch' \
        --env-name='entrez-direct'
}
