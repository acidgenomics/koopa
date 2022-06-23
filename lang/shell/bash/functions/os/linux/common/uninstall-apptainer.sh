#!/usr/bin/env bash

koopa_linux_uninstall_apptainer() {
    koopa_uninstall_app \
        --name='apptainer' \
        --unlink-in-bin='apptainer' \
        "$@"
}
