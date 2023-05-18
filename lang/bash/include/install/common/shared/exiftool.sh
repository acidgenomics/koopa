#!/usr/bin/env bash

main() {
    # """
    # Ensure release is tagged production before submitting.
    # https://exiftool.org/history.html
    # """
    koopa_install_app_subshell \
        --installer='perl-package' \
        --name='exiftool'
}
