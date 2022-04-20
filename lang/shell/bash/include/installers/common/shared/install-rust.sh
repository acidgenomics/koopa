#!/usr/bin/env bash

main() { # {{{1
    # """
    # Install Rust (via rustup).
    # @note Updated 2022-04-15.
    # """
    local app dict
    koopa_assert_has_no_args "$#"
    declare -A app=(
        [cut]="$(koopa_locate_cut)"
        [head]="$(koopa_locate_head)"
    )
    declare -A dict=(
        [prefix]="${INSTALL_PREFIX:?}"
        [tmp_prefix]='rustup'
        [version]="${INSTALL_VERSION:?}" # or 'stable' toolchain
    )
    dict[cargo_home]="${dict[tmp_prefix]}"
    dict[rustup_home]="${dict[tmp_prefix]}"
    CARGO_HOME="${dict[cargo_home]}"
    RUSTUP_HOME="${dict[rustup_home]}"
    export CARGO_HOME RUSTUP_HOME
    koopa_mkdir "${dict[rustup_home]}"
    dict[url]='https://sh.rustup.rs'
    dict[file]='rustup.sh'
    koopa_download "${dict[url]}" "${dict[file]}"
    koopa_chmod 'u+x' "${dict[file]}"
    "./${dict[file]}" -v -y \
        --default-toolchain 'none' \
        --no-modify-path
    app[rustup]="${dict[tmp_prefix]}/bin/rustup"
    koopa_assert_is_installed "${app[rustup]}"
    "${app[rustup]}" install "${dict[version]}"
    "${app[rustup]}" default "${dict[version]}"
    dict[toolchain]="$( \
        "${app[rustup]}" toolchain list \
        | "${app[head]}" -n 1 \
        | "${app[cut]}" -d ' ' -f '1' \
    )"
    dict[toolchain_prefix]="${dict[tmp_prefix]}/toolchains/${dict[toolchain]}"
    koopa_assert_is_dir "${dict[toolchain_prefix]}"
    koopa_cp "${dict[toolchain_prefix]}" "${dict[prefix]}"
    return 0
}
