#!/usr/bin/env bash

koopa_add_conda_env_to_path() {
    # """
    # Add conda environment(s) to PATH.
    # @note Updated 2023-04-04.
    # """
    local name
    koopa_assert_has_args "$#"
    [[ -z "${CONDA_PREFIX:-}" ]] || return 1
    for name in "$@"
    do
        local bin_dir
        bin_dir="${CONDA_PREFIX}/envs/${name}/bin"
        if [[ ! -d "$bin_dir" ]]
        then
            koopa_warn "Conda environment missing: '${bin_dir}'."
            return 1
        fi
        koopa_add_to_path_start "$bin_dir"
    done
    return 0
}
