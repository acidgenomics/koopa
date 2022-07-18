#!/usr/bin/env bash

koopa_install_exiftool() {
    koopa_install_app \
        --installer='perl-package' \
        --link-in-bin='exiftool' \
        --name='exiftool' \
        "$@"
}
