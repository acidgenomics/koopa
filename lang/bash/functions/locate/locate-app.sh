#!/usr/bin/env bash

_koopa_locate_app() {
    local -A bool dict
    local -a pos
    bool['allow_bootstrap']=0
    bool['allow_koopa_bin']=1
    bool['allow_missing']=0
    bool['allow_opt_bin']=1
    bool['allow_system']=0
    bool['only_system']=0
    bool['realpath']=0
    dict['app']=''
    dict['app_name']=''
    dict['bin_name']=''
    dict['system_bin_name']=''
    pos=()
    while (("$#"))
    do
        case "$1" in
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
            '--allow-bootstrap')
                bool['allow_bootstrap']=1
                shift 1
                ;;
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
            '-'*)
                _koopa_invalid_arg "$1"
                ;;
            *)
                pos+=("$1")
                shift 1
                ;;
        esac
    done
    __emit_if_found() {
        [[ -x "${dict['app']}" ]] || return 1
        if [[ "${bool['realpath']}" -eq 1 ]]
        then
            dict['app']="$(_koopa_realpath "${dict['app']}")"
        fi
        printf '%s\n' "${dict['app']}"
    }
    if [[ "${bool['only_system']}" -eq 1 ]]
    then
        bool['allow_bootstrap']=0
        bool['allow_koopa_bin']=0
        bool['allow_system']=1
    fi
    if [[ "${#pos[@]}" -gt 0 ]]
    then
        set -- "${pos[@]}"
        [[ "$#" -eq 1 ]] || return 1
        dict['app']="${1:?}"
        __emit_if_found && return 0
        [[ "${bool['allow_missing']}" -eq 1 ]] && return 0
        _koopa_stop "Failed to locate '${dict['app']}'."
    fi
    [[ -n "${dict['app_name']}" ]] || return 1
    [[ -n "${dict['bin_name']}" ]] || return 1
    if [[ -z "${dict['system_bin_name']}" ]]
    then
        dict['system_bin_name']="${dict['bin_name']}"
    fi
    if [[ "${bool['only_system']}" -eq 1 ]]
    then
        dict['saved_path']="${PATH:?}"
        _koopa_remove_from_path "${KOOPA_PREFIX:?}/bin"
        dict['app']="$(_koopa_which "${dict['system_bin_name']}" || true)"
        export PATH="${dict['saved_path']}"
        __emit_if_found && return 0
    fi
    if [[ "${bool['allow_bootstrap']}" -eq 1 ]]
    then
        dict['app']="${XDG_DATA_HOME:-${HOME:?}/.local/share}/koopa-bootstrap/bin/${dict['bin_name']}"
        __emit_if_found && return 0
    fi
    if [[ "${bool['allow_koopa_bin']}" -eq 1 ]]
    then
        dict['app']="${KOOPA_PREFIX:?}/bin/${dict['bin_name']}"
        __emit_if_found && return 0
    fi
    if [[ "${bool['allow_opt_bin']}" -eq 1 ]]
    then
        dict['app']="${KOOPA_PREFIX:?}/opt/${dict['app_name']}/bin/${dict['bin_name']}"
        __emit_if_found && return 0
    fi
    if [[ "${bool['allow_system']}" -eq 1 ]]
    then
        dict['app']="$(_koopa_which "${dict['system_bin_name']}" || true)"
        __emit_if_found && return 0
    fi
    [[ "${bool['allow_missing']}" -eq 1 ]] && return 0
    if [[ "${bool['allow_system']}" -eq 1 ]]
    then
        _koopa_stop \
            "Failed to locate '${dict['system_bin_name']}'."
    else
        _koopa_stop \
            "Failed to locate '${dict['bin_name']}'." \
            "Run 'koopa install ${dict['app_name']}' to resolve."
    fi
}
