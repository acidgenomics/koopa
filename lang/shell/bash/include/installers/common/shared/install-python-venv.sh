#!/usr/bin/env bash

main() { # {{{
    # """
    # Install Python package as a venv.
    # @note Updated 2022-04-19.
    # """
    local dict
    koopa_assert_has_no_args "$#"
    declare -A dict=(
        [name]="${INSTALL_NAME:?}"
        [prefix]="${INSTALL_PREFIX:?}"
        [version]="${INSTALL_VERSION:?}"
    )
    dict[libexec]="${dict[prefix]}/libexec"
    koopa_python_create_venv \
        --prefix="${dict[libexec]}" \
        "${dict[name]}==${dict[version]}"
    koopa_ln \
        "${dict[libexec]}/bin/${dict[name]}" \
        "${dict[prefix]}/bin/${dict[name]}"
    return 0
}
