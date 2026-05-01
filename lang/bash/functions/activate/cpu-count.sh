#!/usr/bin/env bash

_koopa_cpu_count() {
    local num
    num="${KOOPA_CPU_COUNT:-}"
    if [[ -n "$num" ]]
    then
        _koopa_print "$num"
        return 0
    fi
    local bin_prefix
    bin_prefix="$(_koopa_bin_prefix)"
    local getconf
    getconf='/usr/bin/getconf'
    local nproc
    if [[ -d "$bin_prefix" ]] && [[ -x "${bin_prefix}/gnproc" ]]
    then
        nproc="${bin_prefix}/gnproc"
    else
        nproc=''
    fi
    local python
    if [[ -d "$bin_prefix" ]] && [[ -x "${bin_prefix}/python3" ]]
    then
        python="${bin_prefix}/python3"
    elif [[ -x '/usr/bin/python3' ]]
    then
        python='/usr/bin/python3'
    else
        python=''
    fi
    local sysctl
    sysctl='/usr/sbin/sysctl'
    if [[ -x "$nproc" ]]
    then
        num="$("$nproc" --all)"
    elif [[ -x "$getconf" ]]
    then
        num="$("$getconf" '_NPROCESSORS_ONLN')"
    elif [[ -x "$sysctl" ]] && _koopa_is_macos
    then
        num="$( \
            "$sysctl" -n 'hw.ncpu' \
            | cut -d ' ' -f 2 \
        )"
    elif [[ -x "$python" ]]
    then
        num="$( \
            "$python" -c \
                "import multiprocessing; print(multiprocessing.cpu_count())" \
            2>/dev/null \
            || true \
        )"
    fi
    [[ -z "$num" ]] && num=1
    _koopa_print "$num"
    return 0
}
