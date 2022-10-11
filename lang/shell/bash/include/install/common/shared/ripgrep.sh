#!/usr/bin/env bash

main() {
    koopa_activate_app 'pcre2'
    koopa_install_app_subshell \
        --installer='rust-package' \
        --name='ripgrep' \
        "$@"

}
