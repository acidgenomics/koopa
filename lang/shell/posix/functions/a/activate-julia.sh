#!/bin/sh

_koopa_activate_julia() {
    # """
    # Activate Julia.
    # @note Updated 2022-07-28.
    #
    # Check depot setting with 'Base.DEPOT_PATH'.
    # Check number of cores with 'Threads.nthreads()'.
    #
    # @seealso
    # - https://docs.julialang.org/en/v1/manual/environment-variables/
    # - https://docs.julialang.org/en/v1/manual/multi-threading/
    # - https://github.com/JuliaLang/julia/issues/43949
    # """
    local depot_path num_threads
    [ -x "$(_koopa_bin_prefix)/julia" ] || return 0
    depot_path="$(_koopa_julia_packages_prefix)"
    num_threads="$(_koopa_cpu_count)"
    export JULIA_DEPOT_PATH="$depot_path"
    export JULIA_NUM_THREADS="$num_threads"
    return 0
}
