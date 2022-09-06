#!/usr/bin/env bash

main() {
    koopa_activate_opt_prefix 'pcre2'
    koopa_install_app_passthrough \
        --installer='rust-package' \
        --name='ripgrep' \
        "$@"

}
