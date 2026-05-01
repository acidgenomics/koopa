#!/usr/bin/env bash

_koopa_locate_esearch() {
    _koopa_locate_app \
        --app-name='entrez-direct' \
        --bin-name='esearch' \
        "$@"
}
