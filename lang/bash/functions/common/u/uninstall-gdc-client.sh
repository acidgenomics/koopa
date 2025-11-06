#!/usr/bin/env bash

koopa_uninstall_gdc_client() {
    koopa_uninstall_app \
        --name='gdc-client' \
        "$@"
}
