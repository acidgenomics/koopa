#!/usr/bin/env bash

koopa_install_conda_package() {
    # """
    # Install a conda environment as an application.
    # @note Updated 2023-08-29.
    #
    # Be sure to excluded nested directories that may exist in 'libexec' 'bin',
    # such as 'bin/scripts' for bowtie2.
    #
    # Consider adding 'man1' support for relevant apps (e.g. 'hisat2').
    #
    # @seealso
    # - https://github.com/conda/conda/issues/7741
    # """
    local -A dict
    local -a bin_names create_args pos
    local bin_name
    koopa_assert_is_install_subshell
    dict['name']="${KOOPA_INSTALL_NAME:?}"
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    dict['yaml_file']=''
    pos=()
    while (("$#"))
    do
        case "$1" in
            # Key value pairs --------------------------------------------------
            '--file='*)
                dict['yaml_file']="${1#*=}"
                shift 1
                ;;
            '--file')
                dict['yaml_file']="${2:?}"
                shift 2
                ;;
            '--name='*)
                dict['name']="${1#*=}"
                shift 1
                ;;
            '--name')
                dict['name']="${2:?}"
                shift 2
                ;;
            '--prefix='*)
                dict['prefix']="${1#*=}"
                shift 1
                ;;
            '--prefix')
                dict['prefix']="${2:?}"
                shift 2
                ;;
            '--version='*)
                dict['version']="${1#*=}"
                shift 1
                ;;
            '--version')
                dict['version']="${2:?}"
                shift 2
                ;;
            # Other ------------------------------------------------------------
            '-'*)
                koopa_invalid_arg "$1"
                ;;
            *)
                pos+=("$1")
                shift 1
                ;;
        esac
    done
    [[ "${#pos[@]}" -gt 0 ]] && set -- "${pos[@]}"
    koopa_assert_is_set \
        '--name' "${dict['name']}" \
        '--prefix' "${dict['name']}" \
        '--version' "${dict['name']}"
    create_args=()
    dict['conda_cache_prefix']="$(koopa_init_dir 'conda')"
    export CONDA_PKGS_DIRS="${dict['conda_cache_prefix']}"
    dict['libexec']="$(koopa_init_dir "${dict['prefix']}/libexec")"
    create_args+=("--prefix=${dict['libexec']}")
    if [[ -n "${dict['yaml_file']}" ]]
    then
        create_args+=("--file=${dict['yaml_file']}")
    else
        create_args+=("${dict['name']}==${dict['version']}")
    fi
    koopa_conda_create_env "${create_args[@]}"
    dict['json_pattern']="${dict['name']}-${dict['version']}-*.json"
    case "${dict['name']}" in
        'snakemake')
            dict['json_pattern']="${dict['name']}-minimal-*.json"
            ;;
    esac
    dict['json_file']="$( \
        koopa_find \
            --max-depth=1 \
            --min-depth=1 \
            --pattern="${dict['json_pattern']}" \
            --prefix="${dict['libexec']}/conda-meta" \
            --type='f' \
    )"
    koopa_assert_is_file "${dict['json_file']}"
    readarray -t bin_names <<< "$(koopa_conda_bin "${dict['json_file']}")"
    if koopa_is_array_non_empty "${bin_names[@]:-}"
    then
        for bin_name in "${bin_names[@]}"
        do
            local -A dict2
            dict2['name']="$bin_name"
            dict2['bin_source']="${dict['libexec']}/bin/${dict2['name']}"
            dict2['bin_target']="${dict['prefix']}/bin/${dict2['name']}"
            dict2['man1_source']="${dict['libexec']}/share/man/\
man1/${dict2['name']}.1"
            dict2['man1_target']="${dict['prefix']}/share/man/\
man1/${dict2['name']}.1"
            koopa_assert_is_file "${dict2['bin_source']}"
            koopa_ln "${dict2['bin_source']}" "${dict2['bin_target']}"
            if [[ -f "${dict2['man1_source']}" ]]
            then
                koopa_ln "${dict2['man1_source']}" "${dict2['man1_target']}"
            fi
        done
    fi
    return 0
}
