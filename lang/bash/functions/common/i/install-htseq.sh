#!/usr/bin/env bash

koopa_install_htseq() {
    koopa_install_app \
        --installer='conda-package' \
        --name='htseq' \
        "$@"
}
