#!/usr/bin/env bash

_koopa_locate_shell() { # {{{1
    # """
    # Locate the current shell executable.
    # @note Updated 2021-05-26.
    #
    # Detection issues with qemu ARM emulation on x86:
    # - The 'ps' approach will return correct shell for ARM running via
    #   emulation on x86 (e.g. Docker).
    # - ARM running via emulation on x86 (e.g. Docker) will return
    #   '/usr/bin/qemu-aarch64' here, rather than the shell we want.
    #
    # @seealso
    # - https://stackoverflow.com/questions/3327013
    # - http://opensourceforgeeks.blogspot.com/2013/05/
    #     how-to-find-current-shell-in-linux.html
    # - https://superuser.com/questions/103309/
    # - https://unix.stackexchange.com/questions/87061/
    # - https://unix.stackexchange.com/questions/182590/
    # """
    local proc_file pid sed shell
    shell="${KOOPA_SHELL:-}"
    if [ -x "$shell" ]
    then
        _koopa_print "$shell"
        return 0
    fi
    sed='sed'
    pid="${$}"
    if _koopa_is_linux
    then
        proc_file="/proc/${pid}/exe"
        if [ -x "$proc_file" ] && ! _koopa_is_qemu
        then
            shell="$(_koopa_realpath "$proc_file")"
        elif _koopa_is_installed ps
        then
            shell="$( \
                ps -p "$pid" -o 'comm=' \
                | "$sed" 's/^-//' \
            )"
        fi
    elif _koopa_is_macos
    then
        shell="$( \
            lsof \
                -a \
                -F 'n' \
                -d 'txt' \
                -p "$pid" \
                2>/dev/null \
            | "$sed" -n '3p' \
            | "$sed" 's/^n//' \
        )"
    fi
    [ -n "$shell" ] || return 1
    _koopa_print "$shell"
    return 0
}
