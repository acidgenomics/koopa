#!/usr/bin/env bash

_koopa_locate_gcloud() {
    _koopa_locate_app \
        --app-name='google-cloud-sdk' \
        --bin-name='gcloud' \
        "$@"
}
