#!/usr/bin/env bash

# NOTE We should early return here when no packages need updating.

main() { # {{{1
    # """
    # Update Rust packages.
    # @note Updated 2022-02-10.
    # @seealso
    # - https://crates.io/crates/cargo-update
    # - https://github.com/nabijaczleweli/cargo-update
    # """
    local app
    koopa_assert_has_no_args "$#"
    koopa_activate_rust
    declare -A app=(
        [cargo]="$(koopa_locate_cargo)"
    )
    export RUST_BACKTRACE=1
    koopa_add_to_path_start "$(koopa_dirname "${app[cargo]}")"
    "${app[cargo]}" install-update -a
    return 0
}
