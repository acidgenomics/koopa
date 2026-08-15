#!/usr/bin/env zsh

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
    local num
    num=''
    local candidate
    for candidate in \
        "${SLURM_CPUS_PER_TASK:-}" \
        "${SLURM_CPUS_ON_NODE:-}" \
        "${KOOPA_CPU_COUNT:-}"
    do
        [[ "$candidate" =~ ^[0-9]+$ ]] || continue
        num="$candidate"
        break
    done
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
    local avail
    avail=''
    if [[ -x "$nproc" ]]
    then
        # No '--all': bare nproc honors the CPU affinity mask (e.g. a Slurm
        # cgroup), which is exactly the value 'make --jobs' must respect.
        avail="$("$nproc")"
        [[ "$avail" =~ ^[0-9]+$ ]] || avail=''
    fi
    if [[ -n "$num" ]] && [[ -n "$avail" ]] && [[ "$num" -gt "$avail" ]]
    then
        num="$avail"
    fi
    if [[ -z "$num" ]]
    then
        if [[ -n "$avail" ]]
        then
            num="$avail"
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
    fi
    [[ -z "$num" ]] && num=1
    _koopa_print "$num"
    return 0
}
