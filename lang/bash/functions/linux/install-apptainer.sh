#!/usr/bin/env bash

_koopa_linux_install_apptainer() {
    _koopa_install_app \
        --name='apptainer' \
        --platform='linux' \
        "$@"
}
