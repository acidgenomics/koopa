#!/bin/sh

_koopa_locate_shell() {
    # """
    # Locate the current shell executable.
    # @note Updated 2022-11-14.
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
    local proc_file pid shell
    shell="${KOOPA_SHELL:-}"
    if [ -n "$shell" ]
    then
        _koopa_print "$shell"
        return 0
    fi
    pid="${$}"
    proc_file="/proc/${pid}/exe"
    if [ -x "$proc_file" ] && ! _koopa_is_qemu
    then
        shell="$(koopa_realpath "$proc_file")"
    elif _koopa_is_installed 'ps'
    then
        shell="$( \
            ps -p "$pid" -o 'comm=' \
            | sed 's/^-//' \
        )"
    fi
    # Fallback support for detection failure inside of some subprocesses.
    if [ -z "$shell" ]
    then
        if [ -n "${BASH_VERSION:-}" ]
        then
            shell='bash'
        elif [ -n "${ZSH_VERSION:-}" ]
        then
            shell='zsh'
        fi
    fi
    [ -n "$shell" ] || return 1
    _koopa_print "$shell"
    return 0
}
