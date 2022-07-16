#!/usr/bin/env bash

# FIXME Ensure we unlink in koopa bin.

koopa_debian_uninstall_system_google_cloud_sdk() {
    koopa_uninstall_app \
        --name='google-cloud-sdk' \
        --platform='debian' \
        --system \
        "$@"
}
