#!/bin/sh

_koopa_cpu_count() {
    # """
    # Return a usable number of CPU cores.
    # @note Updated 2023-02-01.
    # """
    local bin_prefix getconf nproc num sysctl
    [ "$#" -eq 0 ] || return 1
    num="${KOOPA_CPU_COUNT:-}"
    if [ -n "$num" ]
    then
        _koopa_print "$num"
        return 0
    fi
    bin_prefix="$(koopa_bin_prefix)"
    nproc="${bin_prefix}/gnproc"
    if [ -x "$nproc" ]
    then
        num="$("$nproc" --all)"
    elif _koopa_is_macos
    then
        sysctl='/usr/sbin/sysctl'
        [ -x "$sysctl" ] || return 1
        num="$("$sysctl" -n 'hw.ncpu')"
    elif _koopa_is_linux
    then
        getconf='/usr/bin/getconf'
        [ -x "$getconf" ] || return 1
        num="$("$getconf" '_NPROCESSORS_ONLN')"
    else
        num=1
    fi
    _koopa_print "$num"
    return 0
}
