#!/usr/bin/env bash

_koopa_uninstall_google_cloud_sdk() {
    _koopa_uninstall_app \
        --name='google-cloud-sdk' \
        "$@"
}
