#!/usr/bin/env bash

koopa_linux_install_apptainer() {
    koopa_install_app \
        --name='apptainer' \
        --platform='linux' \
        "$@"
}
