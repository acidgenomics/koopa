#!/bin/sh

_koopa_cpu_count() {
    # """
    # Return a usable number of CPU cores.
    # @note Updated 2023-03-11.
    # """
    __kvar_num="${KOOPA_CPU_COUNT:-}"
    if [ -n "$__kvar_num" ]
    then
        _koopa_print "$__kvar_num"
        unset -v __kvar_num
        return 0
    fi
    __kvar_bin_prefix="$(_koopa_bin_prefix)"
    __kvar_nproc="${__kvar_bin_prefix}/gnproc"
    unset -v __kvar_bin_prefix
    if [ -x "$__kvar_nproc" ]
    then
        __kvar_num="$("$__kvar_nproc" --all)"
        unset -v __kvar_nproc
    elif _koopa_is_macos
    then
        __kvar_sysctl='/usr/sbin/sysctl'
        [ -x "$__kvar_sysctl" ] || return 1
        __kvar_num="$("$__kvar_sysctl" -n 'hw.ncpu')"
        unset -v __kvar_sysctl
    elif _koopa_is_linux
    then
        __kvar_getconf='/usr/bin/getconf'
        [ -x "$__kvar_getconf" ] || return 1
        __kvar_num="$("$__kvar_getconf" '_NPROCESSORS_ONLN')"
        unset -v __kvar_getconf
    else
        __kvar_num=1
    fi
    [ -n "$__kvar_num" ] || return 1
    _koopa_print "$__kvar_num"
    unset -v __kvar_num
    return 0
}
