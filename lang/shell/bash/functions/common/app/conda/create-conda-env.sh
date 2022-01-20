#!/usr/bin/env bash

koopa::conda_create_env() { # {{{1
    # """
    # Create a conda environment.
    # @note Updated 2022-01-17.
    #
    # Creates a unique environment for each recipe requested.
    # Supports versioning, which will return as 'star@2.7.5a' for example.
    # """
    local app dict pos string
    koopa::assert_has_args "$#"
    declare -A app=(
        [conda]="$(koopa::locate_mamba_or_conda)"
        [cut]="$(koopa::locate_cut)"
    )
    declare -A dict=(
        [conda_prefix]="$(koopa::conda_prefix)"
        [force]=0
        [latest]=0
    )
    pos=()
    while (("$#"))
    do
        case "$1" in
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
                koopa::invalid_arg "$1"
                ;;
            *)
                pos+=("$1")
                shift 1
                ;;
        esac
    done
    [[ "${#pos[@]}" -gt 0 ]] && set -- "${pos[@]}"
    koopa::assert_has_args "$#"
    for string in "$@"
    do
        # Note that we're using 'salmon@1.4.0' for the environment name but
        # must use 'salmon=1.4.0' in the call to conda below.
        dict[env_string]="${string//@/=}"
        if [[ "${dict[latest]}" -eq 1 ]]
        then
            if koopa::str_detect_fixed "${dict[env_string]}" '='
            then
                koopa::stop "Don't specify version when using '--latest'."
            fi
            koopa::alert "Obtaining latest version for '${dict[env_string]}'."
            dict[env_version]="$( \
                koopa::conda_env_latest_version "${dict[env_string]}" \
            )"
            [[ -n "${dict[env_version]}" ]] || return 1
            dict[env_string]="${dict[env_string]}=${dict[env_version]}"
        elif ! koopa::str_detect_fixed "${dict[env_string]}" '='
        then
            dict[env_version]="$( \
                koopa::variable "conda-${dict[env_string]}" \
                || true \
            )"
            if [[ -z "${dict[env_version]}" ]]
            then
                koopa::stop 'Pinned environment version not defined in koopa.'
            fi
            dict[env_string]="${dict[env_string]}=${dict[env_version]}"
        fi
        # Ensure we handle edge case of '<NAME>=<VERSION>=<BUILD>' here.
        dict[env_name]="$( \
            koopa::print "${dict[env_string]//=/@}" \
            | "${app[cut]}" -d '@' -f '1-2' \
        )"
        dict[env_prefix]="${dict[conda_prefix]}/envs/${dict[env_name]}"
        if [[ -d "${dict[env_prefix]}" ]]
        then
            if [[ "${dict[force]}" -eq 1 ]]
            then
                koopa::conda_remove_env "${dict[env_name]}"
            else
                koopa::alert_note "Conda environment '${dict[env_name]}' \
exists at '${dict[env_prefix]}'."
                continue
            fi
        fi
        koopa::alert_install_start "${dict[env_name]}" "${dict[env_prefix]}"
        "${app[conda]}" create \
            --name="${dict[env_name]}" \
            --quiet \
            --yes \
            "${dict[env_string]}"
        koopa::sys_set_permissions --recursive "${dict[env_prefix]}"
        koopa::alert_install_success "${dict[env_name]}" "${dict[env_prefix]}"
    done
    return 0
}
