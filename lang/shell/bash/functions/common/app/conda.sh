#!/usr/bin/env bash

koopa::conda_activate_env() { # {{{1
    # """
    # Activate a conda environment.
    # @note Updated 2022-02-16.
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
    # See also:
    # - https://github.com/conda/conda/issues/7980
    # - https://stackoverflow.com/questions/34534513
    # """
    local dict
    koopa::assert_has_args_eq "$#" 1
    declare -A dict=(
        [env_name]="${1:?}"
        [nounset]="$(koopa::boolean_nounset)"
    )
    dict[env_prefix]="$(koopa::conda_env_prefix "${dict[env_name]}")"
    koopa::assert_is_dir "${dict[env_prefix]}"
    [[ "${dict[nounset]}" -eq 1 ]] && set +u
    koopa::is_conda_env_active && koopa::deactivate_conda
    koopa::activate_conda
    koopa::assert_is_function 'conda'
    conda activate "${dict[env_prefix]}"
    [[ "${dict[nounset]}" -eq 1 ]] && set -u
    return 0
}

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

koopa::conda_env_latest_version() { # {{{1
    # """
    # Get the latest version of a conda environment available.
    # @note Updated 2022-01-17.
    # """
    local app dict str
    koopa::assert_has_args_eq "$#" 1
    declare -A app=(
        [awk]="$(koopa::locate_awk)"
        [conda]="$(koopa::locate_mamba_or_conda)"
        [tail]="$(koopa::locate_tail)"
    )
    declare -A dict=(
        [env_name]="${1:?}"
    )
    # shellcheck disable=SC2016
    str="$( \
        "${app[conda]}" search --quiet "${dict[env_name]}" \
            | "${app[tail]}" -n 1 \
            | "${app[awk]}" '{print $2}'
    )"
    [[ -n "$str" ]] || return 1
    koopa::print "$str"
    return 0
}

koopa::conda_env_list() { # {{{1
    # """
    # Return a list of conda environments in JSON format.
    # @note Updated 2022-01-17.
    # """
    local app str
    koopa::assert_has_no_args "$#"
    declare -A app=(
        [conda]="$(koopa::locate_mamba_or_conda)"
    )
    str="$("${app[conda]}" env list --json --quiet)"
    koopa::print "$str"
    return 0
}

koopa::conda_env_prefix() { # {{{1
    # """
    # Return prefix for a specified conda environment.
    # @note Updated 2022-01-17.
    #
    # Attempt to locate by default path first, which is the fastest approach.
    #
    # Note that we're allowing env_list passthrough as second positional
    # variable, to speed up loading upon activation.
    #
    # Example: koopa::conda_env_prefix 'deeptools'
    #
    # @seealso
    # - conda env list --verbose
    # - conda env list --json
    # - conda info --envs
    # - conda info --json
    # """
    local app dict
    koopa::assert_has_args_le "$#" 2
    declare -A app=(
        [sed]="$(koopa::locate_sed)"
        [tail]="$(koopa::locate_tail)"
    )
    declare -A dict=(
        [env_name]="${1:?}"
        [env_list]="${2:-}"
    )
    [[ -n "${dict[env_name]}" ]] || return 1
    if [[ -z "${dict[env_list]}" ]]
    then
        dict[conda_prefix]="$(koopa::conda_prefix)"
        dict[env_prefix]="${dict[conda_prefix]}/envs/${dict[env_name]}"
        if [[ -d "${dict[env_prefix]}" ]]
        then
            koopa::print "${dict[env_prefix]}"
            return 0
        fi
        dict[env_list]="$(koopa::conda_env_list)"
    fi
    dict[env_list2]="$( \
        koopa::print "${dict[env_list]}" \
            | koopa::grep "${dict[env_name]}" \
    )"
    if [[ -z "${dict[env_list2]}" ]]
    then
        koopa::stop "conda environment does not exist: '${dict[env_name]}'."
    fi
    # Note that this step attempts to automatically match the latest version.
    dict[env_prefix]="$( \
        koopa::print "${dict[env_list]}" \
            | koopa::grep --extended-regexp "/${dict[env_name]}(@[.0-9]+)?\"" \
            | "${app[tail]}" -n 1 \
            | "${app[sed]}" -E 's/^.*"(.+)".*$/\1/' \
    )"
    if [[ ! -d "${dict[env_prefix]}" ]]
    then
        koopa::stop "Failed to resolve conda environment: '${dict[env_name]}'."
    fi
    koopa::print "${dict[env_prefix]}"
    return 0
}

koopa::conda_remove_env() { # {{{1
    # """
    # Remove conda environment.
    # @note Updated 2022-01-17.
    #
    # @seealso
    # - conda env list --verbose
    # - conda env list --json
    #
    # @examples
    # koopa::conda_remove_env 'kallisto' 'salmon'
    # """
    local app dict name
    koopa::assert_has_args "$#"
    declare -A app=(
        [conda]="$(koopa::locate_mamba_or_conda)"
    )
    declare -A dict=(
        [nounset]="$(koopa::boolean_nounset)"
    )
    [[ "${dict[nounset]}" -eq 1 ]] && set +u
    for name in "$@"
    do
        dict[prefix]="$(koopa::conda_env_prefix "$name")"
        koopa::assert_is_dir "${dict[prefix]}"
        dict[name]="$(koopa::basename "${dict[prefix]}")"
        koopa::alert_uninstall_start "${dict[name]}" "${dict[prefix]}"
        # Don't set the '--all' flag here; it can break other recipes.
        "${app[conda]}" env remove --name="${dict[name]}" --yes
        [[ -d "${dict[prefix]}" ]] && koopa::rm "${dict[prefix]}"
        koopa::alert_uninstall_success "${dict[name]}" "${dict[prefix]}"
    done
    [[ "${dict[nounset]}" -eq 1 ]] && set -u
    return 0
}
