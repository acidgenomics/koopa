#!/usr/bin/env bash

koopa_conda_create_env() {
    # """
    # Create a conda environment.
    # @note Updated 2024-07-15.
    #
    # @seealso
    # - https://conda.io/projects/conda/en/latest/user-guide/tasks/
    #     manage-environments.html#sharing-an-environment
    # - https://github.com/conda/conda/issues/6827
    # """
    local -A app bool dict
    local -a pos
    local string
    koopa_assert_has_args "$#"
    app['conda']="$(koopa_locate_conda)"
    app['cut']="$(koopa_locate_cut --allow-system)"
    koopa_assert_is_executable "${app[@]}"
    bool['force']=0
    bool['latest']=0
    bool['tmp_pkg_cache_prefix']=0
    dict['env_prefix']="$(koopa_conda_env_prefix)"
    dict['pkg_cache_prefix']="${CONDA_PKGS_DIRS:-}"
    dict['prefix']=''
    dict['yaml_file']=''
    pos=()
    while (("$#"))
    do
        case "$1" in
            # Passthrough key-value pairs --------------------------------------
            '--channel='*)
                pos+=("$1")
                shift 1
                ;;
            '--channel')
                pos+=("$1" "$2")
                shift 2
                ;;
            # Key-value pairs --------------------------------------------------
            '--file='*)
                dict['yaml_file']="${1#*=}"
                shift 1
                ;;
            '--file')
                dict['yaml_file']="${2:?}"
                shift 2
                ;;
            '--package-cache-prefix='*)
                dict['pkg_cache_prefix']="${1#*=}"
                shift 1
                ;;
            '--package-cache-prefix')
                dict['pkg_cache_prefix']="${2:?}"
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
            # Flags ------------------------------------------------------------
            '--force' | \
            '--reinstall')
                bool['force']=1
                shift 1
                ;;
            '--latest')
                bool['latest']=1
                shift 1
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
    if [[ -z "${dict['pkg_cache_prefix']}" ]]
    then
        bool['tmp_pkg_cache_prefix']=1
        dict['pkg_cache_prefix']="$(koopa_tmp_dir)"
    fi
    koopa_dl 'conda package cache' "${dict['pkg_cache_prefix']}"
    export CONDA_PKGS_DIRS="${dict['pkg_cache_prefix']}"
    if [[ -n "${dict['yaml_file']}" ]]
    then
        koopa_assert_has_no_args "$#"
        koopa_assert_is_dir "${dict['prefix']}"
        [[ "${bool['force']}" -eq 0 ]] || return 1
        [[ "${bool['latest']}" -eq 0 ]] || return 1
        koopa_assert_is_file "${dict['yaml_file']}"
        dict['yaml_file']="$(koopa_realpath "${dict['yaml_file']}")"
        koopa_dl 'conda recipe file' "${dict['yaml_file']}"
        # Note the usage of 'env create' here instead of 'create'.
        "${app['conda']}" env create \
            --file "${dict['yaml_file']}" \
            --prefix "${dict['prefix']}" \
            --quiet
        return 0
    elif [[ -n "${dict['prefix']}" ]]
    then
        koopa_assert_has_args "$#"
        koopa_assert_is_dir "${dict['prefix']}"
        [[ "${bool['force']}" -eq 0 ]] || return 1
        [[ "${bool['latest']}" -eq 0 ]] || return 1
        "${app['conda']}" create \
            --prefix "${dict['prefix']}" \
            --quiet \
            --yes \
            "$@"
        return 0
    fi
    koopa_assert_has_args "$#"
    [[ -z "${dict['yaml_file']}" ]] || return 1
    for string in "$@"
    do
        local -A dict2
        # Note that we're using 'salmon@1.4.0' for the environment name but
        # must use 'salmon=1.4.0' in the call to conda below.
        dict2['env_string']="${string//@/=}"
        if [[ "${bool['latest']}" -eq 1 ]]
        then
            if koopa_str_detect_fixed \
                --string="${dict2['env_string']}" \
                --pattern='='
            then
                koopa_stop "Don't specify version when using '--latest'."
            fi
            koopa_alert "Obtaining latest version for '${dict2['env_string']}'."
            dict2['env_version']="$( \
                koopa_conda_env_latest_version "${dict2['env_string']}" \
            )"
            [[ -n "${dict2['env_version']}" ]] || return 1
            dict2['env_string']="${dict2['env_string']}=${dict2['env_version']}"
        elif ! koopa_str_detect_fixed \
            --string="${dict2['env_string']}" \
            --pattern='='
        then
            dict2['env_version']="$( \
                koopa_app_json_version "${dict2['env_string']}" \
                || true \
            )"
            if [[ -z "${dict2['env_version']}" ]]
            then
                koopa_stop 'Pinned environment version not defined in koopa.'
            fi
            dict2['env_string']="${dict2['env_string']}=${dict2['env_version']}"
        fi
        # Ensure we handle edge case of '<NAME>=<VERSION>=<BUILD>' here.
        dict2['env_name']="$( \
            koopa_print "${dict2['env_string']//=/@}" \
            | "${app['cut']}" -d '@' -f '1-2' \
        )"
        dict2['env_prefix']="${dict['env_prefix']}/${dict2['env_name']}"
        if [[ -d "${dict2['env_prefix']}" ]]
        then
            if [[ "${bool['force']}" -eq 1 ]]
            then
                koopa_conda_remove_env "${dict2['env_name']}"
            else
                koopa_alert_note "Conda environment '${dict2['env_name']}' \
exists at '${dict2['env_prefix']}'."
                continue
            fi
        fi
        koopa_alert_install_start \
            "${dict2['env_name']}" "${dict2['env_prefix']}"
        "${app['conda']}" create \
            --name="${dict2['env_name']}" \
            --quiet \
            --yes \
            "${dict2['env_string']}"
        koopa_alert_install_success \
            "${dict2['env_name']}" "${dict2['env_prefix']}"
    done
    if [[ "${bool['tmp_pkg_cache_prefix']}" -eq 1 ]]
    then
        koopa_rm "${dict['pkg_cache_prefix']}"
    fi
    return 0
}
