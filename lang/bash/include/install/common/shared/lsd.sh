#!/usr/bin/env bash

main() {
    local version
    version="${KOOPA_INSTALL_VERSION:?}"
    koopa_install_app_subshell \
        --installer='rust-package' \
        --name='lsd' \
        -D '--git=https://github.com/lsd-rs/lsd.git' \
        -D "--tag=v${version}"
}
