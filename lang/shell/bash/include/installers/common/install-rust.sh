#!/usr/bin/env bash

install_rust() { # {{{1
    # """
    # Install Rust (via rustup).
    # @note Updated 2022-01-24.
    # """
    local dict
    koopa_assert_has_no_args "$#"
    declare -A dict=(
        [prefix]="${INSTALL_PREFIX:?}"
        [version]="${INSTALL_VERSION:?}"
    )
    dict[pkg_prefix]="$(koopa_rust_packages_prefix "${dict[version]}")"
    RUSTUP_HOME="${dict[prefix]}"
    CARGO_HOME="${dict[pkg_prefix]}"
    export CARGO_HOME RUSTUP_HOME
    koopa_configure_rust
    koopa_sys_mkdir "${dict[prefix]}"
    dict[url]='https://sh.rustup.rs'
    dict[file]='rustup.sh'
    koopa_download "${dict[url]}" "${dict[file]}"
    koopa_chmod 'u+x' "${dict[file]}"
    # Can get the version of install script with '--version' here.
    "./${dict[file]}" --no-modify-path -v -y
    koopa_sys_set_permissions --recursive "${dict[pkg_prefix]}"
    return 0
}
