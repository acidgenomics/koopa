#!/usr/bin/env bash

koopa_locate_app() { # {{{1
    # """
    # Locate file system path to an application.
    # @note Updated 2022-04-04.
    #
    # App locator prioritization:
    # 1. Allow for direct input of a program path.
    # 2. Check in make prefix (e.g. '/usr/local').
    # 3. Check in koopa opt.
    # 4. Check in Homebrew opt.
    # 5. Check in system library.
    #
    # Resolving the full executable path can cause BusyBox coreutils to error.
    # """
    if [[ "$#" -eq 1 ]] && \
        [[ -x "${1:?}" ]] && \
        koopa_is_installed "${1:?}"
    then
        koopa_print "${1:?}"
        return 0
    fi
    local dict pos
    declare -A dict=(
        [app_name]=''
        [brew_app]=''
        [brew_opt_name]=''
        [brew_prefix]="$(koopa_homebrew_prefix)"
        [homebrew_gnubin]=0
        [koopa_app]=''
        [koopa_bin_prefix]="$(koopa_bin_prefix)"
        [koopa_opt_name]=''
        [koopa_opt_prefix]="$(koopa_opt_prefix)"
        [make_prefix]="$(koopa_make_prefix)"
    )
    pos=()
    while (("$#"))
    do
        case "$1" in
            # Key-value pairs --------------------------------------------------
            '--app-name='*)
                dict[app_name]="${1#*=}"
                shift 1
                ;;
            '--app-name')
                dict[app_name]="${2:?}"
                shift 2
                ;;
            '--homebrew-opt-name='*)
                dict[brew_opt_name]="${1#*=}"
                shift 1
                ;;
            '--homebrew-opt-name')
                dict[brew_opt_name]="${2:?}"
                shift 2
                ;;
            '--koopa-opt-name='*)
                dict[koopa_opt_name]="${1#*=}"
                shift 1
                ;;
            '--koopa-opt-name')
                dict[koopa_opt_name]="${2:?}"
                shift 2
                ;;
            '--opt-name='*)
                dict[brew_opt_name]="${1#*=}"
                dict[koopa_opt_name]="${1#*=}"
                shift 1
                ;;
            '--opt-name')
                dict[brew_opt_name]="${2:?}"
                dict[koopa_opt_name]="${2:?}"
                shift 2
                ;;
            # Flags ------------------------------------------------------------
            '--homebrew-gnubin')
                dict[homebrew_gnubin]=1
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
    koopa_assert_has_args_le "$#" 1
    [[ -z "${dict[app_name]}" ]] && dict[app_name]="${1:?}"
    dict[koopa_bin_app]="${dict[koopa_bin_prefix]}/${dict[app_name]}"
    if [[ -x "${dict[koopa_bin_app]}" ]]
    then
        koopa_print "${dict[koopa_bin_app]}"
        return 0
    fi
    [[ -z "${dict[koopa_opt_name]}" ]] && \
        dict[koopa_opt_name]="${dict[app_name]}"
    dict[koopa_opt_app]="${dict[koopa_opt_prefix]}/${dict[koopa_opt_name]}/\
bin/${dict[app_name]}"
    if [[ -x "${dict[koopa_opt_app]}" ]]
    then
        koopa_print "${dict[koopa_opt_app]}"
        return 0
    fi
    [[ -z "${dict[brew_opt_name]}" ]] && \
        dict[brew_opt_name]="${dict[app_name]}"
    if [[ "${dict[homebrew_gnubin]}" -eq 1 ]]
    then
        dict[brew_opt_app]="${dict[brew_prefix]}/opt/${dict[brew_opt_name]}/\
libexec/gnubin/${dict[app_name]}"
    else
        dict[brew_opt_app]="${dict[brew_prefix]}/opt/${dict[brew_opt_name]}/\
bin/${dict[app_name]}"
    fi
    if [[ -x "${dict[brew_opt_app]}" ]]
    then
        koopa_print "${dict[brew_opt_app]}"
        return 0
    fi
    dict[make_app]="${dict[make_prefix]}/bin/${dict[app_name]}"
    if [[ -x "${dict[make_app]}" ]]
    then
        koopa_print "${dict[make_app]}"
        return 0
    fi
    dict[app]="$(koopa_which "${dict[app_name]}" || true)"
    if { \
        [[ -n "${dict[app]}" ]] && \
        [[ -x "${dict[app]}" ]] && \
        [[ ! -d "${dict[app]}" ]] && \
        koopa_is_installed "${dict[app]}"; \
    }
    then
        koopa_print "${dict[app]}"
    fi
    koopa_warn "Failed to locate '${dict[app_name]}'."
    return 1
}

koopa_locate_conda_app() { # {{{1
    # """
    # Locate conda application.
    # @note Updated 2022-01-10.
    # """
    local dict pos
    koopa_assert_has_args "$#"
    declare -A dict=(
        [app_name]=''
        [conda_prefix]="$(koopa_conda_prefix)"
        [env_name]=''
        [env_version]=''
    )
    pos=()
    while (("$#"))
    do
        case "$1" in
            # Key-value pairs --------------------------------------------------
            '--app-name='*)
                dict[app_name]="${1#*=}"
                shift 1
                ;;
            '--app-name')
                dict[app_name]="${2:?}"
                shift 2
                ;;
            '--conda-prefix='*)
                dict[conda_prefix]="${1#*=}"
                shift 1
                ;;
            '--conda-prefix')
                dict[conda_prefix]="${2:?}"
                shift 2
                ;;
            '--env-name='*)
                dict[env_name]="${1#*=}"
                shift 1
                ;;
            '--env-name')
                dict[env_name]="${2:?}"
                shift 2
                ;;
            '--env-version='*)
                dict[env_version]="${1#*=}"
                shift 1
                ;;
            '--env-version')
                dict[env_version]="${2:?}"
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
    koopa_assert_has_args_le "$#" 1
    # Allow simple input using a single positional argument for name.
    if [[ -z "${dict[app_name]}" ]]
    then
        koopa_assert_has_args_eq "$#" 1
        dict[app_name]="${1:?}"
    fi
    if [[ -z "${dict[env_name]}" ]]
    then
        dict[env_name]="${dict[app_name]}"
    fi
    if [[ -z "${dict[env_version]}" ]]
    then
        dict[env_version]="$(koopa_variable "conda-${dict[env_name]}")"
        # Slower approach that isn't version pinned:
        # > dict[env_version]="$( \
        # >     koopa_conda_env_latest_version "${dict[env_name]}" \
        # > )"
    fi
    koopa_assert_is_set \
        '--app-name' "${dict[app_name]}" \
        '--conda-prefix' "${dict[conda_prefix]}" \
        '--env-name' "${dict[env_name]}" \
        '--env-version' "${dict[env_version]}"
    dict[app_path]="${dict[conda_prefix]}/envs/\
${dict[env_name]}@${dict[env_version]}/bin/${dict[app_name]}"
    koopa_assert_is_executable "${dict[app_path]}"
    koopa_print "${dict[app_path]}"
    return 0
}

koopa_locate_gnu_coreutils_app() { # {{{1
    # """
    # Locate a GNU coreutils app.
    # @note Updated 2022-04-04.
    koopa_locate_app \
        --app-name="${1:?}" \
        --homebrew-gnubin \
        --opt-name='coreutils'
}
