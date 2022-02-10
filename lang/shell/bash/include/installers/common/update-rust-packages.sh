#!/usr/bin/env bash

koopa:::update_rust_packages() { # {{{1
    # """
    # Update Rust packages.
    # @note Updated 2022-02-10.
    # @seealso
    # - https://crates.io/crates/cargo-update
    # - https://github.com/nabijaczleweli/cargo-update
    # """
    local app
    koopa::assert_has_no_args "$#"
    koopa::activate_rust
    declare -A app=(
        [cargo]="$(koopa::locate_cargo)"
    )
    export RUST_BACKTRACE=1
    koopa::add_to_path_start "$(koopa::dirname "${app[cargo]}")"
    "${app[cargo]}" install-update -a
    return 0
}
