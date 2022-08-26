#!/usr/bin/env bash

koopa_locate_esearch() {
    koopa_locate_app \
        --app-name='entrez-direct' \
        --bin-name='esearch' \
        "$@" 
}
