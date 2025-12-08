#!/usr/bin/env bash

koopa_install_illumina_ica_cli() {
    koopa_assert_is_not_arm64
    koopa_install_app \
        --name='illumina-ica-cli' \
        "$@"
}
