#!/bin/sh

_koopa_cpu_count() {
    # """
    # Return a usable number of CPU cores.
    # @note Updated 2026-08-14.
    #
    # Precedence: an explicit Slurm allocation (SLURM_CPUS_PER_TASK, then
    # SLURM_CPUS_ON_NODE) beats a possibly stale inherited KOOPA_CPU_COUNT,
    # which beats an affinity-aware nproc probe, which beats getconf/sysctl/
    # python. Each candidate is accepted only when it parses as a positive
    # integer -- Slurm also exports 'SLURM_JOB_CPUS_PER_NODE', but in a
    # compressed multi-node form such as '4(x2)' that must never reach
    # 'make --jobs' verbatim, so that name is deliberately not read here.
    #
    # The affinity-aware nproc result also clamps the final value: koopa must
    # never spawn more build jobs than the current CPU allocation, even when
    # a Slurm variable or KOOPA_CPU_COUNT claims otherwise.
    # """
    __kvar_num=''
    for __kvar_candidate in \
        "${SLURM_CPUS_PER_TASK:-}" \
        "${SLURM_CPUS_ON_NODE:-}" \
        "${KOOPA_CPU_COUNT:-}"
    do
        case "$__kvar_candidate" in
            '' | *[!0-9]*) continue ;;
        esac
        __kvar_num="$__kvar_candidate"
        break
    done
    unset -v __kvar_candidate
    __kvar_bin_prefix="$(_koopa_bin_prefix)"
    __kvar_getconf='/usr/bin/getconf'
    if [ -d "$__kvar_bin_prefix" ] && [ -x "${__kvar_bin_prefix}/gnproc" ]
    then
        __kvar_nproc="${__kvar_bin_prefix}/gnproc"
    else
        __kvar_nproc=''
    fi
    if [ -d "$__kvar_bin_prefix" ] && [ -x "${__kvar_bin_prefix}/python3" ]
    then
        __kvar_python="${__kvar_bin_prefix}/python3"
    elif [ -x '/usr/bin/python3' ]
    then
        __kvar_python='/usr/bin/python3'
    else
        __kvar_python=''
    fi
    __kvar_sysctl='/usr/sbin/sysctl'
    __kvar_avail=''
    if [ -x "$__kvar_nproc" ]
    then
        # No '--all': bare nproc honors the CPU affinity mask (e.g. a Slurm
        # cgroup), which is exactly the value 'make --jobs' must respect.
        __kvar_avail="$("$__kvar_nproc")"
        case "$__kvar_avail" in
            '' | *[!0-9]*) __kvar_avail='' ;;
        esac
    fi
    if [ -n "$__kvar_num" ] && [ -n "$__kvar_avail" ] \
        && [ "$__kvar_num" -gt "$__kvar_avail" ]
    then
        __kvar_num="$__kvar_avail"
    fi
    if [ -z "$__kvar_num" ]
    then
        if [ -n "$__kvar_avail" ]
        then
            __kvar_num="$__kvar_avail"
        elif [ -x "$__kvar_getconf" ]
        then
            __kvar_num="$("$__kvar_getconf" '_NPROCESSORS_ONLN')"
        elif [ -x "$__kvar_sysctl" ] && _koopa_is_macos
        then
            __kvar_num="$( \
                "$__kvar_sysctl" -n 'hw.ncpu' \
                | cut -d ' ' -f 2 \
            )"
        elif [ -x "$__kvar_python" ]
        then
            __kvar_num="$( \
                "$__kvar_python" -c \
                    "import multiprocessing; print(multiprocessing.cpu_count())" \
                2>/dev/null \
                || true \
            )"
        fi
    fi
    [ -z "$__kvar_num" ] && __kvar_num=1
    _koopa_print "$__kvar_num"
    unset -v \
        __kvar_avail \
        __kvar_bin_prefix \
        __kvar_getconf \
        __kvar_nproc \
        __kvar_num \
        __kvar_python \
        __kvar_sysctl
    return 0
}
