#!/usr/bin/env bash

koopa_locate_efetch() {
    koopa_locate_app \
        --app-name='entrez-direct' \
        --bin-name='efetch'
        "$@" \
}
