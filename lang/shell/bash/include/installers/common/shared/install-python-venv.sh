#!/usr/bin/env bash

main() { # {{{
    # """
    # Install Python package as a venv.
    # @note Updated 2022-04-26.
    # """
    local bin_name bin_names dict
    koopa_assert_has_no_args "$#"
    declare -A dict=(
        [name]="${INSTALL_NAME:?}"
        [prefix]="${INSTALL_PREFIX:?}"
        [version]="${INSTALL_VERSION:?}"
    )
    dict[libexec]="${dict[prefix]}/libexec"
    case "${dict[name]}" in
        'pytaglib')
            bin_names=('pyprinttags')
            ;;
        'ranger-fm')
            bin_names=('ranger')
            ;;
        *)
            bin_names=("${dict[name]}")
            ;;
    esac
    koopa_python_create_venv \
        --prefix="${dict[libexec]}" \
        "${dict[name]}==${dict[version]}"
    for bin_name in "${bin_names[@]}"
    do
        koopa_ln \
            "${dict[libexec]}/bin/${bin_name}" \
            "${dict[prefix]}/bin/${bin_name}"
    done
    return 0
}
