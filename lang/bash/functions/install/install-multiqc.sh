#!/usr/bin/env bash

_koopa_install_multiqc() {
    _koopa_install_app \
        --installer='python-package' \
        --name='multiqc' \
        "$@"
}
