function _koopa_activate_conda
    # Activate conda.
    # @note Updated 2026-05-12.
    set -l prefix (_koopa_opt_prefix)/conda
    if not test -d "$prefix"
        return 0
    end
    set -l conda "$prefix/bin/conda"
    if not test -x "$conda"
        return 0
    end
    functions -q conda; and functions -e conda
    eval ($conda shell.fish hook)
end
