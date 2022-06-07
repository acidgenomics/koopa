#!/usr/bin/env bash

# FIXME Need to add support for linking into 'bin/' here.
# FIXME For our installers, should we set a custom install prefix?
# FIXME Can map '--prefix' to change the environment path.
# FIXME Consider putting prefix in libexec and then linking into bin
# similar to our Python virtual environment approach.
# FIXME Consider reworking this for ffq, bowtie2, gget, salmon, snakemake, etc.
# FIXME Don't allow installation of multiple environments in a single call?

koopa_conda_create_env() {
    # """
    # Create a conda environment.
    # @note Updated 2022-06-03.
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
    for string in "$@"
    do
        # Note that we're using 'salmon@1.4.0' for the environment name but
        # must use 'salmon=1.4.0' in the call to conda below.
        dict[env_string]="${string//@/=}"
        if [[ "${dict[latest]}" -eq 1 ]]
        then
            if koopa_str_detect_fixed \
                --string="${dict[env_string]}" \
                --pattern='='
            then
                koopa_stop "Don't specify version when using '--latest'."
            fi
            koopa_alert "Obtaining latest version for '${dict[env_string]}'."
            dict[env_version]="$( \
                koopa_conda_env_latest_version "${dict[env_string]}" \
            )"
            [[ -n "${dict[env_version]}" ]] || return 1
            dict[env_string]="${dict[env_string]}=${dict[env_version]}"
        elif ! koopa_str_detect_fixed \
            --string="${dict[env_string]}" \
            --pattern='='
        then
            dict[env_version]="$( \
                koopa_variable "conda-${dict[env_string]}" \
                || true \
            )"
            if [[ -z "${dict[env_version]}" ]]
            then
                koopa_stop 'Pinned environment version not defined in koopa.'
            fi
            dict[env_string]="${dict[env_string]}=${dict[env_version]}"
        fi
        # Ensure we handle edge case of '<NAME>=<VERSION>=<BUILD>' here.
        dict[env_name]="$( \
            koopa_print "${dict[env_string]//=/@}" \
            | "${app[cut]}" -d '@' -f '1-2' \
        )"
        dict[env_prefix]="${dict[conda_prefix]}/envs/${dict[env_name]}"
        if [[ -d "${dict[env_prefix]}" ]]
        then
            if [[ "${dict[force]}" -eq 1 ]]
            then
                koopa_conda_remove_env "${dict[env_name]}"
            else
                koopa_alert_note "Conda environment '${dict[env_name]}' \
exists at '${dict[env_prefix]}'."
                continue
            fi
        fi
        koopa_alert_install_start "${dict[env_name]}" "${dict[env_prefix]}"
        "${app[conda]}" create \
            --name="${dict[env_name]}" \
            --quiet \
            --yes \
            "${dict[env_string]}"
        koopa_sys_set_permissions --recursive \
            "${dict[conda_prefix]}/pkgs" \
            "${dict[env_prefix]}"
        koopa_alert_install_success "${dict[env_name]}" "${dict[env_prefix]}"
    done
    return 0
}
