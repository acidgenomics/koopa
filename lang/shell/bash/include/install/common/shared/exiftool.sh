#!/usr/bin/env bash

main() {
    koopa_install_app_passthrough \
        --installer='perl-package' \
        --name='exiftool' \
        "$@"
}
