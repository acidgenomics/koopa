#!/usr/bin/env bash

koopa_locate_app() {
    # """
    # Locate file system path to an application.
    # @note Updated 2023-03-31.
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
    local -A bool=(
        ['allow_koopa_bin']=1
        ['allow_missing']=0
        ['allow_system']=0
        ['only_system']=0
        ['realpath']=0
    )
    local -A dict=(
        ['app']=''
        ['app_name']=''
        ['bin_name']=''
        ['bin_prefix']="$(koopa_bin_prefix)"
        ['opt_prefix']="$(koopa_opt_prefix)"
        ['system_bin_name']=''
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
            '--system-bin-name='*)
                dict['system_bin_name']="${1#*=}"
                shift 1
                ;;
            '--system-bin-name')
                dict['system_bin_name']="${2:?}"
                shift 2
                ;;
            # Flags ------------------------------------------------------------
            '--allow-missing')
                bool['allow_missing']=1
                shift 1
                ;;
            '--allow-system')
                bool['allow_system']=1
                shift 1
                ;;
            '--no-allow-koopa-bin')
                bool['allow_koopa_bin']=0
                shift 1
                ;;
            '--only-system')
                bool['only_system']=1
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
    if [[ "${bool['only_system']}" -eq 1 ]]
    then
        bool['allow_koopa_bin']=0
        bool['allow_system']=1
    fi
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
    if [[ "${bool['allow_koopa_bin']}" -eq 1 ]]
    then
        dict['app']="${dict['bin_prefix']}/${dict['bin_name']}"
    fi
    if [[ -x "${dict['app']}" ]]
    then
        if [[ "${bool['realpath']}" -eq 1 ]]
        then
            dict['app']="$(koopa_realpath "${dict['app']}")"
        fi
        koopa_print "${dict['app']}"
        return 0
    fi
    if [[ "${bool['only_system']}" -eq 0 ]]
    then
        dict['app']="${dict['opt_prefix']}/${dict['app_name']}/\
bin/${dict['bin_name']}"
    fi
    if [[ ! -x "${dict['app']}" ]] && [[ "${bool['allow_system']}" -eq 1 ]]
    then
        [[ -z "${dict['system_bin_name']}" ]] && \
            dict['system_bin_name']="${dict['bin_name']}"
        if [[ -x "/usr/local/bin/${dict['system_bin_name']}" ]]
        then
            dict['app']="/usr/local/bin/${dict['system_bin_name']}"
        elif [[ -x "/usr/bin/${dict['system_bin_name']}" ]]
        then
            dict['app']="/usr/bin/${dict['system_bin_name']}"
        elif [[ -x "/bin/${dict['system_bin_name']}" ]]
        then
            dict['app']="/bin/${dict['system_bin_name']}"
        fi
    fi
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
    if [[ "${bool['allow_system']}" -eq 1 ]]
    then
        koopa_stop \
            "Failed to locate '${dict['system_bin_name']}'."
    else
        koopa_stop \
            "Failed to locate '${dict['bin_name']}'." \
            "Run 'koopa install ${dict['app_name']}' to resolve."
    fi
}
