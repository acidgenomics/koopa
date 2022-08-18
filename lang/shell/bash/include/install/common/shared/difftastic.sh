#!/usr/bin/env bash

main() {
    koopa_install_app_internal \
        --name='difftastic' \
        --installer='rust-package' \
        "$@"
}
