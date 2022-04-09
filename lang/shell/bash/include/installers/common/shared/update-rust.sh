#!/usr/bin/env bash

main() { # {{{1
    # """
    # Update Rust.
    # @note Updated 2022-04-09.
    # """
    local app dict
    koopa_assert_has_no_args "$#"
    declare -A app
    declare -A dict=(
        [prefix]="${UPDATE_PREFIX:?}"
    )
    dict[cargo_home]="${dict[prefix]}"
    dict[rustup_home]="${dict[prefix]}/rustup"
    app[rustup]="${dict[cargo_home]}/bin/rustup"
    koopa_assert_is_installed "${app[rustup]}"
    koopa_add_to_path_start "${dict[cargo_home]}/bin"
    CARGO_HOME="${dict[cargo_home]}"
    RUSTUP_HOME="${dict[rustup_home]}"
    export CARGO_HOME RUSTUP_HOME
    export RUST_BACKTRACE='full'
    # > "${app[rustup]}" toolchain list
    "${app[rustup]}" update
    return 0
}
