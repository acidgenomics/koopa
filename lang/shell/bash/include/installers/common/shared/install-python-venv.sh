#!/usr/bin/env bash

main() {
    # """
    # Install a Python package as a virtual environment application.
    # @note Updated 2022-06-15.
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
        'azure-cli')
            bin_names=('az')
            ;;
        'pygments')
            bin_names=('pygmentize')
            ;;
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
