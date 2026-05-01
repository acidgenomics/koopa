#!/usr/bin/env bash

_koopa_locate_efetch() {
    _koopa_locate_app \
        --app-name='entrez-direct' \
        --bin-name='efetch' \
        "$@"
}
