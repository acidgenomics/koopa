#!/usr/bin/env bash

koopa_locate_app() {
    # """
    # Locate file system path to an application.
    # @note Updated 2022-08-26.
    #
    # Mode 1: direct executable file path input.
    # Mode 2: '--app-name' and '--bin-name' input.
    #
    # App locator prioritization:
    # 1. Direct file path input of an executable.
    # 2. Check for linked program in koopa bin.
    # 3. Check for linked program in in koopa opt.
    #
    # Resolving the full executable path can cause BusyBox coreutils to error.
    # """
    local bool dict pos
    declare -A bool=(
        ['allow_missing']=0
        ['realpath']=0
    )
    declare -A dict=(
        ['app_name']=''
        ['bin_name']=''
        ['bin_prefix']="$(koopa_bin_prefix)"
        ['opt_prefix']="$(koopa_opt_prefix)"
    )
    pos=()
    while (("$#"))
    do
        case "$1" in
            # Key-value pairs --------------------------------------------------
            '--app-name='*)
                dict['app_name']="${1#*=}"
                shift 1
                ;;
            '--app-name')
                dict['app_name']="${2:?}"
                shift 2
                ;;
            '--bin-name='*)
                dict['bin_name']="${1#*=}"
                shift 1
                ;;
            '--bin-name')
                dict['bin_name']="${2:?}"
                shift 2
                ;;
            # Flags ------------------------------------------------------------
            '--allow-missing')
                bool['allow_missing']=1
                shift 1
                ;;
            '--realpath')
                bool['realpath']=1
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
    if [[ "${#pos[@]}" -gt 0 ]]
    then
        set -- "${pos[@]}"
        [[ "$#" -eq 1 ]] || return 1
        dict['app']="${1:?}"
        if [[ -x "${dict['app']}" ]] && \
            koopa_is_installed "${dict['app']}"
        then
            if [[ "${bool['realpath']}" -eq 1 ]]
            then
                dict['app']="$(koopa_realpath "${dict['app']}")"
            fi
            koopa_print "${dict['app']}"
            return 0
        fi
        [[ "${bool['allow_missing']}" -eq 1 ]] && return 0
        koopa_stop "Failed to locate '${dict['app']}'."
    fi
    [[ -n "${dict['app_name']}" ]] || return 1
    [[ -n "${dict['bin_name']}" ]] || return 1
    dict['app']="${dict['bin_prefix']}/${dict['bin_name']}"
    if [[ -x "${dict['app']}" ]]
    then
        if [[ "${bool['realpath']}" -eq 1 ]]
        then
            dict['app']="$(koopa_realpath "${dict['app']}")"
        fi
        koopa_print "${dict['app']}"
        return 0
    fi
    dict['app']="${dict['opt_prefix']}/${dict['app_name']}/\
bin/${dict['bin_name']}"
    if [[ -x "${dict['app']}" ]]
    then
        if [[ "${bool['realpath']}" -eq 1 ]]
        then
            dict['app']="$(koopa_realpath "${dict['app']}")"
        fi
        koopa_print "${dict['app']}"
        return 0
    fi
    [[ "${bool['allow_missing']}" -eq 1 ]] && return 0
    koopa_stop \
        "Failed to locate '${dict['bin_name']}' (from '${dict['app_name']}')." \
        "Running 'koopa install '${dict['app_name']}' may resolve the issue."
}
