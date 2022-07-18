#!/usr/bin/env bash

koopa_install_entrez_direct() {
    koopa_install_app \
        --installer='conda-env' \
        --link-in-bin='efetch' \
        --link-in-bin='esearch' \
        --name='entrez-direct' \
        "$@"
}
