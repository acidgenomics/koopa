#!/usr/bin/env bash

# FIXME Now seeing this pop up:
# !! Error: Not file: '[0-9]+\.[0-9]+(\.[0-9]+)?(\.[0-9]+)?([a-z])?([0-9]+)?'.
# FIXME Need to rework this using dict approach.s

koopa:::install_rust() { # {{{1
    # """
    # Install Rust (via rustup).
    # @note Updated 2021-06-17.
    # """
    local file pkg_prefix prefix url version
    prefix="${INSTALL_PREFIX:?}"
    version="${INSTALL_VERSION:?}"
    # FIXME Rework this, passing in Rust directly? Need to move this to configure?
    pkg_prefix="$(koopa::rust_packages_prefix "$version")"
    RUSTUP_HOME="$prefix"
    CARGO_HOME="$pkg_prefix"
    export CARGO_HOME RUSTUP_HOME
    koopa::dl \
        'RUSTUP_HOME' "$RUSTUP_HOME" \
        'CARGO_HOME' "$CARGO_HOME"
    koopa::configure_rust
    koopa::sys_mkdir "$prefix"
    url='https://sh.rustup.rs'
    file='rustup.sh'
    koopa::download "$url" "$file"
    koopa::chmod 'u+x' "$file"
    # Can get the version of install script with '--version' here.
    "./${file}" --no-modify-path -v -y
    koopa::sys_set_permissions --recursive "$pkg_prefix"
    return 0
}
