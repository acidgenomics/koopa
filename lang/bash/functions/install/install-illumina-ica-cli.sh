#!/usr/bin/env bash

_koopa_install_illumina_ica_cli() {
    _koopa_assert_is_not_arm64
    _koopa_install_app \
        --name='illumina-ica-cli' \
        "$@"
}
