#!/usr/bin/env bash

koopa_locate_gcloud() {
    koopa_locate_app \
        --app-name='google-cloud-sdk' \
        --bin-name='gcloud' \
        "$@"
}
