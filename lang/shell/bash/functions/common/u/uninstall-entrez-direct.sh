#!/usr/bin/env bash

koopa_uninstall_entrez_direct() {
    koopa_install_app \
        --name='entrez-direct' \
        --unlink-in-bin='efetch' \
        --unlink-in-bin='esearch' \
        "$@"
}
