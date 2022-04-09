#!/usr/bin/env bash

main() { # {{{1
    # """
    # Install Rust (via rustup).
    # @note Updated 2022-04-09.
    # """
    local app dict
    koopa_assert_has_no_args "$#"
    declare -A app
    declare -A dict=(
        [prefix]="${INSTALL_PREFIX:?}"
        [version]="${INSTALL_VERSION:?}"
        [toolchain]='stable'
    )
    dict[cargo_home]="${dict[prefix]}"
    dict[rustup_home]="${dict[prefix]}/rustup"
    CARGO_HOME="${dict[cargo_home]}"
    RUSTUP_HOME="${dict[rustup_home]}"
    export CARGO_HOME RUSTUP_HOME
    koopa_add_to_path_start "${dict[cargo_home]}/bin"
    koopa_mkdir "${dict[rustup_home]}"
    dict[url]='https://sh.rustup.rs'
    dict[file]='rustup.sh'
    koopa_download "${dict[url]}" "${dict[file]}"
    koopa_chmod 'u+x' "${dict[file]}"
    # Can get the version of install script with '--version' here.
    "./${dict[file]}" --no-modify-path -v -y
    app[rustup]="${dict[prefix]}/bin/rustup"
    koopa_assert_is_installed "${app[rustup]}"
    "${app[rustup]}" install "${dict[toolchain]}"
    "${app[rustup]}" default "${dict[toolchain]}"
    "${app[rustup]}" toolchain list
    return 0
}
