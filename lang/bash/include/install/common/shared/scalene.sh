#!/usr/bin/env bash

main() {
    koopa_assert_is_not_aarch64
    koopa_install_app_subshell \
        --installer='python-package' \
        --name='scalene'
}
