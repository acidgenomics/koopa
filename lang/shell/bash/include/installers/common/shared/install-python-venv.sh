#!/usr/bin/env bash

main() {
    # """
    # Install a Python package as a virtual environment application.
    # @note Updated 2022-08-11.
    # """
    local app bin_name bin_names dict
    koopa_assert_has_no_args "$#"
    declare -A app=(
        [cut]="$(koopa_locate_cut)"
        [python]="$(koopa_locate_python)"
    )
    [[ -x "${app[cut]}" ]] || return 1
    [[ -x "${app[python]}" ]] || return 1
    declare -A dict=(
        [name]="${INSTALL_NAME:?}"
        [prefix]="${INSTALL_PREFIX:?}"
        [version]="${INSTALL_VERSION:?}"
    )
    dict[libexec]="${dict[prefix]}/libexec"
    # NOTE Consider reworking the case-sensitivity edge case handling here.
    case "${dict[name]}" in
        'glances')
            dict[pkg_name]='Glances'
            ;;
        'pygments')
            dict[pkg_name]='Pygments'
            ;;
        'scons')
            dict[pkg_name]='SCons'
            ;;
        *)
            dict[pkg_name]="$(koopa_snake_case_simple "${dict[name]}")"
            ;;
    esac
    dict[py_version]="$(koopa_get_version "${app[python]}")"
    dict[py_maj_min_ver]="$(koopa_major_minor_version "${dict[py_version]}")"
    koopa_python_create_venv \
        --prefix="${dict[libexec]}" \
        "${dict[pkg_name]}==${dict[version]}"
    dict[record_file]="${dict[libexec]}/lib/python${dict[py_maj_min_ver]}/\
site-packages/${dict[pkg_name]}-${dict[version]}.dist-info/RECORD"
    koopa_assert_is_file "${dict[record_file]}"
    # Ensure we exclude any nested subdirectories in libexec bin, which is
    # known to happen with some conda recipes (e.g. bowtie2).
    readarray -t bin_names <<< "$( \
        koopa_grep \
            --file="${dict[record_file]}" \
            --pattern='^\.\./\.\./\.\./bin/[^/]+,' \
            --regex \
        | "${app[cut]}" -d ',' -f '1' \
        | "${app[cut]}" -d '/' -f '5' \
    )"
    koopa_assert_is_array_non_empty "${bin_names[@]:-}"
    for bin_name in "${bin_names[@]}"
    do
        koopa_ln \
            "${dict[libexec]}/bin/${bin_name}" \
            "${dict[prefix]}/bin/${bin_name}"
    done
    return 0
}
