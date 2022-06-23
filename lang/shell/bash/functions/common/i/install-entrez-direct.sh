#!/usr/bin/env bash

koopa_install_entrez_direct() {
    koopa_install_app \
        --installer='conda-env' \
        --link-in-bin='bin/efetch' \
        --link-in-bin='bin/esearch' \
        --name='entrez-direct' \
        "$@"
}
