#!/usr/bin/env bash

koopa_locate_app() {
    # """
    # Locate file system path to an application.
    # @note Updated 2022-04-26.
    #
    # App locator prioritization:
    # 1. Allow for direct input of an executable.
    # 2. Check in koopa opt.
    # 3. Check in 'PATH', when '--allow-in-path' is declared.
    #
    # Resolving the full executable path can cause BusyBox coreutils to error.
    # """
    local dict pos
    declare -A dict=(
        [allow_in_path]=0
        [allow_missing]=0
        [app_name]=''
        [bin_prefix]="$(koopa_bin_prefix)"
        [opt_name]=''
        [opt_prefix]="$(koopa_opt_prefix)"
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
            '--opt-name='*)
                dict[opt_name]="${1#*=}"
                shift 1
                ;;
            '--opt-name')
                dict[opt_name]="${2:?}"
                shift 2
                ;;
            # Flags ------------------------------------------------------------
            '--allow-in-path')
                dict[allow_in_path]=1
                shift 1
                ;;
            '--allow-missing')
                dict[allow_missing]=1
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
    if [[ "$#" -gt 0 ]]
    then
        koopa_assert_has_args_eq "$#" 1
        if [[ -n "${dict[app_name]}" ]] || \
            [[ "${dict[allow_in_path]}" -eq 1 ]]
        then
            koopa_stop "Need to rework locator for '${1:?}'."
        fi
        dict[app]="${1:?}"
        if [[ -x "${dict[app]}" ]] && koopa_is_installed "${dict[app]}"
        then
            koopa_print "${dict[app]}"
            return 0
        fi
        koopa_stop "Failed to locate '${dict[app]}'."
    fi
    dict[app]="${dict[bin_prefix]}/${dict[app_name]}"
    if [[ -x "${dict[app]}" ]]
    then
        koopa_print "${dict[app]}"
        return 0
    fi
    if [[ -n "${dict[opt_name]}" ]]
    then
        dict[app]="${dict[opt_prefix]}/${dict[opt_name]}/bin/${dict[app_name]}"
        if [[ -x "${dict[app]}" ]]
        then
            koopa_print "${dict[app]}"
            return 0
        elif [[ ! -x "${dict[app]}" ]] && \
            [[ "${dict[allow_in_path]}" -eq 0 ]] && \
            [[ "${dict[allow_missing]}" -eq 0 ]]
        then
            koopa_stop "Need to install '${dict[opt_name]}' for '${dict[app]}'."
        fi
    fi
    if [[ "${dict[allow_in_path]}" -eq 1 ]]
    then
        dict[app]="$(koopa_which "${dict[app_name]}" || true)"
    fi
    if { \
        [[ -n "${dict[app]}" ]] && \
        [[ -x "${dict[app]}" ]] && \
        [[ ! -d "${dict[app]}" ]] && \
        koopa_is_installed "${dict[app]}"; \
    }
    then
        koopa_print "${dict[app]}"
        return 0
    fi
    [[ "${dict[allow_missing]}" -eq 1 ]] && return 0
    koopa_stop "Failed to locate '${dict[app_name]}'."
}
