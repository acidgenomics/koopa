#!/usr/bin/env bash

koopa_install_gdc_client() {
    koopa_install_app \
        --installer='conda-package' \
        --name='gdc-client' \
        "$@"
}
