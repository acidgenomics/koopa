#!/bin/sh

_koopa_activate_julia() {
    # """
    # Activate Julia.
    # @note Updated 2023-03-09.
    #
    # Check depot setting with 'Base.DEPOT_PATH'.
    # Check number of cores with 'Threads.nthreads()'.
    #
    # @seealso
    # - https://docs.julialang.org/en/v1/manual/environment-variables/
    # - https://docs.julialang.org/en/v1/manual/multi-threading/
    # - https://github.com/JuliaLang/julia/issues/43949
    # """
    [ -x "$(_koopa_bin_prefix)/julia" ] || return 0
    JULIA_DEPOT_PATH="$(_koopa_julia_packages_prefix)"
    JULIA_NUM_THREADS="$(_koopa_cpu_count)"
    export JULIA_DEPOT_PATH JULIA_NUM_THREADS
    return 0
}
