#!/usr/bin/env bash

update_rust() { # {{{1
    # """
    # Install Rust.
    # @note Updated 2021-11-22.
    # """
    local app dict
    koopa_assert_has_no_args "$#"
    koopa_activate_rust
    declare -A app=(
        [rustup]="$(koopa_locate_rustup)"
    )
    declare -A dict=(
        [cargo_home]="${CARGO_HOME:?}"
        [rustup_home]="${RUSTUP_HOME:?}"
    )
    export RUST_BACKTRACE='full'
    # rustup v1.21.0 fix.
    # https://github.com/rust-lang/rustup/issues/2166
    koopa_mkdir "${dict[rustup_home]}/downloads"
    # rustup v1.21.1 fix.
    koopa_rm "${dict[cargo_home]}/bin/"{'cargo-fmt','rustfmt'}
    "${app[rustup]}" update
    koopa_sys_set_permissions --recursive "${dict[cargo_home]}"
    return 0
}
