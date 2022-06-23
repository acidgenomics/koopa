#!/usr/bin/env bash

koopa_linux_install_apptainer() {
    koopa_install_app \
        --link-in-bin='bin/apptainer' \
        --name='apptainer' \
        --platform='linux' \
        "$@"
}
