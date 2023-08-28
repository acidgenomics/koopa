#!/usr/bin/env bash

main() {
    local version
    version="${KOOPA_INSTALL_VERSION:?}"
    koopa_install_app_subshell \
        --installer='rust-package' \
        --name='ripgrep-all' \
        -D '--cargo-name=ripgrep_all' \
        -D '--git=https://github.com/phiresky/ripgrep-all.git' \
        -D "--tag=v${version}"
}
