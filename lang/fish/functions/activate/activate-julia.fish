function _koopa_activate_julia
    # Activate Julia environment variables.
    # @note Updated 2026-06-13.
    test -x "$KOOPA_PREFIX/bin/julia"; or return 0
    set -gx JULIA_DEPOT_PATH "$HOME/.julia"
    set -gx JULIA_NUM_THREADS "$KOOPA_CPU_COUNT"
end
