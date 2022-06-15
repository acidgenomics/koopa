#!/usr/bin/env bash

main() {
    # """
    # Install a conda environment as an application.
    # @note Updated 2022-06-15.
    # """
    koopa_assert_has_no_args "$#"
    declare -A dict=(
        [name]="${INSTALL_NAME:?}"
        [prefix]="${INSTALL_PREFIX:?}"
        [version]="${INSTALL_VERSION:?}"
    )
    dict[libexec]="$(koopa_init_dir "${dict[prefix]}/libexec")"
    case "${dict[name]}" in
        'ghostscript')
            bin_names=('gs')
            ;;
        *)
            bin_names=("${dict[name]}")
            ;;
    esac
    koopa_conda_create_env \
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
