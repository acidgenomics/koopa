#!/bin/sh

_koopa_locate_shell() {
    # """
    # Locate the current shell (name, not absolute path).
    # @note Updated 2023-03-10.
    #
    # Don't use 'lsof' on macOS, as it can hang on NFS shares
    # (see '-b' flag for details).
    #
    # Detection issues with qemu ARM emulation on x86:
    # - The 'ps' approach will return correct shell for ARM running via
    #   emulation on x86 (e.g. Docker).
    # - ARM running via emulation on x86 (e.g. Docker) will return
    #   '/usr/bin/qemu-aarch64' here, rather than the shell we want.
    #
    # @seealso
    # - https://stackoverflow.com/questions/3327013/
    # - http://opensourceforgeeks.blogspot.com/2013/05/
    #     how-to-find-current-shell-in-linux.html
    # - https://superuser.com/questions/103309/
    # - https://unix.stackexchange.com/questions/87061/
    # - https://unix.stackexchange.com/questions/182590/
    # """
    __kvar_shell="${KOOPA_SHELL:-}"
    if [ -n "$__kvar_shell" ]
    then
        _koopa_print "$__kvar_shell"
        unset -v __kvar_shell
        return 0
    fi
    __kvar_pid="${$}"
    if _koopa_is_installed 'ps'
    then
        __kvar_shell="$( \
            ps -p "$__kvar_pid" -o 'comm=' \
            | sed 's/^-//' \
        )"
    elif _koopa_is_linux
    then
        __kvar_proc_file="/proc/${__kvar_pid}/exe"
        [ -f "$__kvar_proc_file" ] || return 1
        __kvar_shell="$(_koopa_realpath "$__kvar_proc_file")"
        __kvar_shell="$(basename "$__kvar_shell")"
        unset -v __kvar_proc_file
    else
        if [ -n "${BASH_VERSION:-}" ]
        then
            __kvar_shell='bash'
        elif [ -n "${KSH_VERSION:-}" ]
        then
            __kvar_shell='ksh'
        elif [ -n "${ZSH_VERSION:-}" ]
        then
            __kvar_shell='zsh'
        else
            __kvar_shell='sh'
        fi
    fi
    [ -n "$__kvar_shell" ] || return 1
    case "$__kvar_shell" in
        '/bin/sh' | 'sh')
            __kvar_shell="$(_koopa_realpath '/bin/sh')"
            ;;
    esac
    _koopa_print "$__kvar_shell"
    unset -v __kvar_pid __kvar_shell
    return 0
}
