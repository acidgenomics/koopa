#!/usr/bin/env bash

koopa:::install_rust() { # {{{1
    # """
    # Install Rust (via rustup).
    # @note Updated 2022-01-24.
    # """
    local dict
    declare -A dict=(
        [prefix]="${INSTALL_PREFIX:?}"
        [version]="${INSTALL_VERSION:?}"
    )
    dict[pkg_prefix]="$(koopa::rust_packages_prefix "${dict[version]}")"
    RUSTUP_HOME="${dict[prefix]}"
    CARGO_HOME="${dict[pkg_prefix]}"
    export CARGO_HOME RUSTUP_HOME
    koopa::configure_rust
    koopa::sys_mkdir "${dict[prefix]}"
    dict[url]='https://sh.rustup.rs'
    dict[file]='rustup.sh'
    koopa::download "${dict[url]}" "${dict[file]}"
    koopa::chmod 'u+x' "${dict[file]}"
    # Can get the version of install script with '--version' here.
    "./${dict[file]}" --no-modify-path -v -y
    koopa::sys_set_permissions --recursive "${dict[pkg_prefix]}"
    return 0
}
