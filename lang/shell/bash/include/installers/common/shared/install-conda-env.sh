#!/usr/bin/env bash

# FIXME snakemake needs to map to snakemake-minimal.

main() {
    # """
    # Install a conda environment as an application.
    # @note Updated 2022-07-29.
    # """
    local app bin_names dict
    koopa_assert_has_no_args "$#"
    declare -A app=(
        [cut]="$(koopa_locate_cut)"
        [jq]="$(koopa_locate_jq)"
    )
    [[ -x "${app[cut]}" ]] || return 1
    [[ -x "${app[jq]}" ]] || return 1
    declare -A dict=(
        [name]="${INSTALL_NAME:?}"
        [prefix]="${INSTALL_PREFIX:?}"
        [version]="${INSTALL_VERSION:?}"
    )
    dict[libexec]="$(koopa_init_dir "${dict[prefix]}/libexec")"
    koopa_conda_create_env \
        --prefix="${dict[libexec]}" \
        "${dict[name]}==${dict[version]}"
    dict[json_pattern]="${dict[name]}-${dict[version]}-*.json"
    case "${dict[name]}" in
        'snakemake')
            dict[json_pattern]="${dict[name]}-minimal-*.json"
            ;;
    esac
    dict[json_file]="$( \
        koopa_find \
            --max-depth=1 \
            --min-depth=1 \
            --pattern="${dict[json_pattern]}" \
            --prefix="${dict[libexec]}/conda-meta" \
            --type='f' \
    )"
    koopa_assert_is_file "${dict[json_file]}"
    readarray -t bin_names <<< "$( \
        "${app[jq]}" --raw-output '.files[]' "${dict[json_file]}" \
            | koopa_grep --pattern='^bin/' --regex \
            | "${app[cut]}" -d '/' -f '2' \
    )"
    if koopa_is_array_non_empty "${bin_names[@]:-}"
    then
        for bin_name in "${bin_names[@]}"
        do
            koopa_ln \
                "${dict[libexec]}/bin/${bin_name}" \
                "${dict[prefix]}/bin/${bin_name}"
        done
    fi
    return 0
}
