#!/usr/bin/env bash

koopa_linux_install_ont_bonito() {
    koopa_install_app \
        --installer='python-package' \
        --name='ont-bonito' \
        "$@"
}
