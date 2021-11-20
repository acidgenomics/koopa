#!/usr/bin/env bash

koopa:::update_rust() { # {{{1
    # """
    # Install Rust.
    # @note Updated 2021-11-19.
    # """
    local app dict
    koopa::activate_rust
    declare -A app=(
        [rustup]="$(koopa::locate_rustup)"
    )
    declare -A dict=(
        [cargo_home]="${CARGO_HOME:?}"
        [rustup_home]="${RUSTUP_HOME:?}"
    )
    export RUST_BACKTRACE='full'
    # rustup v1.21.0 fix.
    # https://github.com/rust-lang/rustup/issues/2166
    koopa::mkdir "${dict[rustup_home]}/downloads"
    # rustup v1.21.1 fix.
    koopa::rm "${dict[cargo_home]}/bin/"{'cargo-fmt','rustfmt'}
    "${app[rustup]}" update
    koopa::sys_set_permissions --recursive "${dict[cargo_home]}"
    return 0
}
