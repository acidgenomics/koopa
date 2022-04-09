#!/usr/bin/env bash

# FIXME Consider adding support for linkage of useful programs directly into
# '/opt/koopa/bin' from here.

koopa_conda_activate_env() { # {{{1
    # """
    # Activate a conda environment.
    # @note Updated 2022-03-16.
    #
    # Designed to work inside calling scripts and/or subshells.
    #
    # Currently, the conda activation script returns a 'conda()' function in
    # the current shell that doesn't propagate to subshells. This function
    # attempts to rectify the current situation.
    #
    # Don't use absolute path to conda binary here. Needs to use the conda
    # function sourced in shell session, otherwise you will hit an
    # initialization error.
    #
    # Note that the conda activation script currently has unbound variables
    # (e.g. PS1), that will cause this step to fail unless we temporarily
    # disable unbound variable checks.
    #
    # Alternate approach:
    # > eval "$(conda shell.bash hook)"
    #
    # @seealso
    # - https://github.com/conda/conda/issues/7980
    # - https://stackoverflow.com/questions/34534513
    # """
    local dict
    koopa_assert_has_args_eq "$#" 1
    declare -A dict=(
        [env_name]="${1:?}"
        [nounset]="$(koopa_boolean_nounset)"
    )
    dict[env_prefix]="$(koopa_conda_env_prefix "${dict[env_name]}" || true)"
    if [[ ! -d "${dict[env_prefix]}" ]]
    then
        koopa_alert_info "Attempting to install missing conda \
environment '${dict[env_name]}'."
        koopa_conda_create_env "${dict[env_name]}"
        dict[env_prefix]="$(koopa_conda_env_prefix "${dict[env_name]}" || true)"
    fi
    if [[ ! -d "${dict[env_prefix]}" ]]
    then
        koopa_stop "'${dict[env_name]}' conda environment is not installed."
    fi
    [[ "${dict[nounset]}" -eq 1 ]] && set +o nounset
    koopa_is_conda_env_active && koopa_conda_deactivate
    koopa_activate_conda
    koopa_assert_is_function 'conda'
    conda activate "${dict[env_prefix]}"
    [[ "${dict[nounset]}" -eq 1 ]] && set -o nounset
    return 0
}

koopa_conda_create_env() { # {{{1
    # """
    # Create a conda environment.
    # @note Updated 2022-03-16.
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
            | "${app[cut]}" --delimiter='@' --fields='1-2' \
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

koopa_conda_deactivate() { # {{{1
    # """
    # Deactivate Conda environment.
    # @note Updated 2022-03-16.
    # """
    local dict
    koopa_assert_has_no_args "$#"
    declare -A dict=(
        [env_name]="$(koopa_conda_env_name)"
        [nounset]="$(koopa_boolean_nounset)"
    )
    if [[ -z "${dict[env_name]}" ]]
    then
        koopa_stop 'conda is not active.'
    fi
    koopa_assert_is_function 'conda'
    [[ "${dict[nounset]}" -eq 1 ]] && set +o nounset
    conda deactivate
    [[ "${dict[nounset]}" -eq 1 ]] && set -o nounset
    return 0
}

koopa_conda_env_latest_version() { # {{{1
    # """
    # Get the latest version of a conda environment available.
    # @note Updated 2022-01-17.
    # """
    local app dict str
    koopa_assert_has_args_eq "$#" 1
    declare -A app=(
        [awk]="$(koopa_locate_awk)"
        [conda]="$(koopa_locate_mamba_or_conda)"
        [tail]="$(koopa_locate_tail)"
    )
    declare -A dict=(
        [env_name]="${1:?}"
    )
    # shellcheck disable=SC2016
    str="$( \
        "${app[conda]}" search --quiet "${dict[env_name]}" \
            | "${app[tail]}" --lines=1 \
            | "${app[awk]}" '{print $2}'
    )"
    [[ -n "$str" ]] || return 1
    koopa_print "$str"
    return 0
}

koopa_conda_env_list() { # {{{1
    # """
    # Return a list of conda environments in JSON format.
    # @note Updated 2022-01-17.
    # """
    local app str
    koopa_assert_has_no_args "$#"
    declare -A app=(
        [conda]="$(koopa_locate_mamba_or_conda)"
    )
    str="$("${app[conda]}" env list --json --quiet)"
    koopa_print "$str"
    return 0
}

koopa_conda_env_prefix() { # {{{1
    # """
    # Return prefix for a specified conda environment.
    # @note Updated 2022-03-16.
    #
    # Attempt to locate by default path first, which is the fastest approach.
    #
    # Note that we're allowing env_list passthrough as second positional
    # variable, to speed up loading upon activation.
    #
    # Example: koopa_conda_env_prefix 'deeptools'
    #
    # @seealso
    # - conda env list --verbose
    # - conda env list --json
    # - conda info --envs
    # - conda info --json
    # """
    local app dict
    koopa_assert_has_args_le "$#" 2
    declare -A app=(
        [sed]="$(koopa_locate_sed)"
        [tail]="$(koopa_locate_tail)"
    )
    declare -A dict=(
        [env_name]="${1:?}"
        [env_list]="${2:-}"
    )
    [[ -n "${dict[env_name]}" ]] || return 1
    if [[ -z "${dict[env_list]}" ]]
    then
        dict[conda_prefix]="$(koopa_conda_prefix)"
        dict[env_prefix]="${dict[conda_prefix]}/envs/${dict[env_name]}"
        if [[ -d "${dict[env_prefix]}" ]]
        then
            koopa_print "${dict[env_prefix]}"
            return 0
        fi
        dict[env_list]="$(koopa_conda_env_list)"
    fi
    dict[env_list2]="$( \
        koopa_grep \
            --pattern="${dict[env_name]}" \
            --string="${dict[env_list]}" \
    )"
    [[ -n "${dict[env_list2]}" ]] || return 1
    # Note that this step attempts to automatically match the latest version.
    dict[env_prefix]="$( \
        koopa_grep \
            --pattern="/${dict[env_name]}(@[.0-9]+)?\"" \
            --regex \
            --string="${dict[env_list]}" \
        | "${app[tail]}" --lines=1 \
        | "${app[sed]}" -E 's/^.*"(.+)".*$/\1/' \
    )"
    [[ -d "${dict[env_prefix]}" ]] || return 1
    koopa_print "${dict[env_prefix]}"
    return 0
}

koopa_conda_remove_env() { # {{{1
    # """
    # Remove conda environment.
    # @note Updated 2022-01-17.
    #
    # @seealso
    # - conda env list --verbose
    # - conda env list --json
    #
    # @examples
    # > koopa_conda_remove_env 'kallisto' 'salmon'
    # """
    local app dict name
    koopa_assert_has_args "$#"
    declare -A app=(
        [conda]="$(koopa_locate_mamba_or_conda)"
    )
    declare -A dict=(
        [nounset]="$(koopa_boolean_nounset)"
    )
    [[ "${dict[nounset]}" -eq 1 ]] && set +o nounset
    for name in "$@"
    do
        dict[prefix]="$(koopa_conda_env_prefix "$name")"
        koopa_assert_is_dir "${dict[prefix]}"
        dict[name]="$(koopa_basename "${dict[prefix]}")"
        koopa_alert_uninstall_start "${dict[name]}" "${dict[prefix]}"
        # Don't set the '--all' flag here; it can break other recipes.
        "${app[conda]}" env remove --name="${dict[name]}" --yes
        [[ -d "${dict[prefix]}" ]] && koopa_rm "${dict[prefix]}"
        koopa_alert_uninstall_success "${dict[name]}" "${dict[prefix]}"
    done
    [[ "${dict[nounset]}" -eq 1 ]] && set -o nounset
    return 0
}
