#!/usr/bin/env bash

koopa_conda_create_env() {
    # """
    # Create a conda environment.
    # @note Updated 2022-06-15.
    #
    # Creates a unique environment for each recipe requested.
    # Supports versioning, which will return as 'star@2.7.5a' for example.
    # """
    local app dict pos string
    koopa_assert_has_args "$#"
    declare -A app=(
        [conda]="$(koopa_locate_mamba_or_conda)"
        [cut]="$(koopa_locate_cut)"
    )
    declare -A dict=(
        [conda_prefix]="$(koopa_conda_prefix)"
        [force]=0
        [latest]=0
        [prefix]=''
    )
    pos=()
    while (("$#"))
    do
        case "$1" in
            # Key value pairs --------------------------------------------------
            '--prefix='*)
                dict[prefix]="${1#*=}"
                shift 1
                ;;
            '--prefix')
                dict[prefix]="${2:?}"
                shift 2
                ;;
            # Flags ------------------------------------------------------------
            '--force' | \
            '--reinstall')
                dict[force]=1
                shift 1
                ;;
            '--latest')
                dict[latest]=1
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
    koopa_assert_has_args "$#"
    if [[ -n "${dict[prefix]}" ]]
    then
        koopa_assert_has_args_eq "$#" 1
        koopa_assert_is_dir "${dict[prefix]}"
        "${app[conda]}" create \
            --prefix "${dict[prefix]}" \
            --quiet \
            --yes \
            "$@"
        return 0
    fi
    for string in "$@"
    do
        local dict2
        declare -A dict2
        # Note that we're using 'salmon@1.4.0' for the environment name but
        # must use 'salmon=1.4.0' in the call to conda below.
        dict2[env_string]="${string//@/=}"
        if [[ "${dict[latest]}" -eq 1 ]]
        then
            if koopa_str_detect_fixed \
                --string="${dict2[env_string]}" \
                --pattern='='
            then
                koopa_stop "Don't specify version when using '--latest'."
            fi
            koopa_alert "Obtaining latest version for '${dict2[env_string]}'."
            dict2[env_version]="$( \
                koopa_conda_env_latest_version "${dict2[env_string]}" \
            )"
            [[ -n "${dict2[env_version]}" ]] || return 1
            dict2[env_string]="${dict2[env_string]}=${dict2[env_version]}"
        elif ! koopa_str_detect_fixed \
            --string="${dict2[env_string]}" \
            --pattern='='
        then
            dict2[env_version]="$( \
                koopa_variable "${dict2[env_string]}" \
                || true \
            )"
            if [[ -z "${dict2[env_version]}" ]]
            then
                koopa_stop 'Pinned environment version not defined in koopa.'
            fi
            dict2[env_string]="${dict2[env_string]}=${dict2[env_version]}"
        fi
        # Ensure we handle edge case of '<NAME>=<VERSION>=<BUILD>' here.
        dict2[env_name]="$( \
            koopa_print "${dict2[env_string]//=/@}" \
            | "${app[cut]}" -d '@' -f '1-2' \
        )"
        dict2[env_prefix]="${dict[conda_prefix]}/envs/${dict2[env_name]}"
        if [[ -d "${dict2[env_prefix]}" ]]
        then
            if [[ "${dict[force]}" -eq 1 ]]
            then
                koopa_conda_remove_env "${dict2[env_name]}"
            else
                koopa_alert_note "Conda environment '${dict2[env_name]}' \
exists at '${dict2[env_prefix]}'."
                continue
            fi
        fi
        koopa_alert_install_start "${dict2[env_name]}" "${dict2[env_prefix]}"
        "${app[conda]}" create \
            --name="${dict2[env_name]}" \
            --quiet \
            --yes \
            "${dict2[env_string]}"
        koopa_sys_set_permissions --recursive \
            "${dict[conda_prefix]}/pkgs" \
            "${dict2[env_prefix]}"
        koopa_alert_install_success "${dict2[env_name]}" "${dict2[env_prefix]}"
    done
    return 0
}
