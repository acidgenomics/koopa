#!/usr/bin/env bash

main() {
    # """
    # Install Rust (via rustup).
    # @note Updated 2024-10-21.
    #
    # Consider using 'rustup toolchain install' here.
    # """
    local -A app dict
    app['cut']="$(koopa_locate_cut --allow-system)"
    app['head']="$(koopa_locate_head --allow-system)"
    koopa_assert_is_executable "${app[@]}"
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['tmp_prefix']='rustup'
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    dict['cargo_home']="${dict['tmp_prefix']}"
    dict['rustup_home']="${dict['tmp_prefix']}"
    CARGO_HOME="${dict['cargo_home']}"
    RUSTUP_HOME="${dict['rustup_home']}"
    RUSTUP_INIT_SKIP_PATH_CHECK='yes'
    export CARGO_HOME RUSTUP_HOME RUSTUP_INIT_SKIP_PATH_CHECK
    koopa_mkdir "${dict['rustup_home']}"
    dict['url']='https://sh.rustup.rs'
    dict['file']='rustup.sh'
    koopa_download "${dict['url']}" "${dict['file']}"
    koopa_chmod 'u+x' "${dict['file']}"
    "./${dict['file']}" -v -y \
        --default-toolchain 'none' \
        --no-modify-path
    app['rustup']="${dict['tmp_prefix']}/bin/rustup"
    koopa_assert_is_installed "${app['rustup']}"
    koopa_add_to_path_start "$(koopa_realpath "${dict['tmp_prefix']}/bin")"
    koopa_print_env
    "${app['rustup']}" --verbose \
        install "${dict['version']}"
    "${app['rustup']}" --verbose \
        default "${dict['version']}"
    dict['toolchain']="$( \
        "${app['rustup']}" toolchain list \
        | "${app['head']}" -n 1 \
        | "${app['cut']}" -d ' ' -f '1' \
    )"
    dict['toolchain_prefix']="${dict['tmp_prefix']}/toolchains/\
${dict['toolchain']}"
    koopa_assert_is_dir "${dict['toolchain_prefix']}"
    koopa_cp --verbose "${dict['toolchain_prefix']}" "${dict['prefix']}"
    return 0
}
