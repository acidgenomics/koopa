#!/usr/bin/env zsh

_koopa_locate_shell() {
    local shell
    shell="${KOOPA_SHELL:-}"
    if [[ -n "$shell" ]]
    then
        _koopa_print "$shell"
        return 0
    fi
    local pid
    pid="${$}"
    if _koopa_is_installed 'ps'
    then
        shell="$( \
            ps -p "$pid" -o 'comm=' \
            | sed 's/^-//' \
        )"
    elif _koopa_is_linux
    then
        local proc_file
        proc_file="/proc/${pid}/exe"
        [[ -f "$proc_file" ]] || return 1
        shell="$(_koopa_realpath "$proc_file")"
        shell="$(basename "$shell")"
    else
        if [[ -n "${BASH_VERSION:-}" ]]
        then
            shell='bash'
        elif [[ -n "${KSH_VERSION:-}" ]]
        then
            shell='ksh'
        elif [[ -n "${ZSH_VERSION:-}" ]]
        then
            shell='zsh'
        else
            shell='sh'
        fi
    fi
    [[ -n "$shell" ]] || return 1
    case "$shell" in
        '/bin/sh' | 'sh')
            shell="$(_koopa_realpath '/bin/sh')"
            ;;
    esac
    _koopa_print "$shell"
    return 0
}
