#!/bin/sh

koopa_activate_julia() {
    # """
    # Activate Julia.
    # @note Updated 2022-07-28.
    #
    # Check number of cores with 'Threads.nthreads()'.
    #
    # How to set 'JULIA_DEPOT_PATH':
    # > local depot_path
    # > depot_path="$(koopa_julia_packages_prefix)"
    # > [ -d "$depot_path" ] || return 0
    # > export JULIA_DEPOT_PATH="$depot_path"
    #
    # @seealso
    # - https://docs.julialang.org/en/v1/manual/environment-variables/
    # - https://docs.julialang.org/en/v1/manual/multi-threading/
    # - https://github.com/JuliaLang/julia/issues/43949
    # """
    local num_threads
    [ -x "$(koopa_bin_prefix)/julia" ] || return 0
    num_threads="$(koopa_cpu_count)"
    export JULIA_NUM_THREADS="$num_threads"
    return 0
}
