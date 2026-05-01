function _koopa_activate_conda
    # Activate conda.
    # @note Updated 2026-05-01.
    set -l conda_prefix (string replace -r '/bin$' '' (_koopa_bin_prefix))
    set conda_prefix "$KOOPA_PREFIX/app/conda"
    set -l latest_dir ""
    if test -d "$conda_prefix"
        for d in $conda_prefix/*/
            set latest_dir "$d"
        end
    end
    if test -z "$latest_dir"
        return 0
    end
    set -l conda "$latest_dir/bin/conda"
    if not test -x "$conda"
        return 0
    end
    functions -q conda; and functions -e conda
    eval ($conda shell.fish hook)
end
