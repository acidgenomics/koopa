#!/usr/bin/env bash

main() { # {{{1
    # """
    # Update Rust packages.
    # @note Updated 2022-04-11.
    #
    # @seealso
    # - https://crates.io/crates/cargo-update
    # - https://github.com/nabijaczleweli/cargo-update
    # """
    local app dict
    koopa_assert_has_no_args "$#"
    koopa_activate_opt_prefix 'rust'
    koopa_is_macos && koopa_activate_opt_prefix 'openssl'
    declare -A app
    declare -A dict=(
        [opt_prefix]="$(koopa_opt_prefix)"
        [pkgs_prefix]="$(koopa_rust_packages_prefix)"
    )
    dict[rust_prefix]="${dict[opt_prefix]}/rust"
    dict[cargo_home]="${dict[rust_prefix]}"
    dict[rustup_home]="${dict[rust_prefix]}/rustup"
    app[cargo]="${dict[cargo_home]}/bin/cargo"
    koopa_add_to_path_start "${dict[pkgs_prefix]}/bin"
    CARGO_HOME="${dict[cargo_home]}"
    RUSTUP_HOME="${dict[rustup_home]}"
    export CARGO_HOME RUSTUP_HOME
    if koopa_is_macos
    then
        export OPENSSL_DIR="${dict[opt_prefix]}/openssl"
    fi
    export RUST_BACKTRACE=1
    "${app[cargo]}" install-update -a
    return 0
}
