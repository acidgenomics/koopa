#!/usr/bin/env bash

koopa::add_conda_env_to_path() { # {{{1
    # """
    # Add conda environment(s) to PATH.
    # @note Updated 2020-06-30.
    # """
    local bin_dir name
    koopa::assert_has_args "$#"
    koopa::assert_is_installed conda
    [[ -z "${CONDA_PREFIX:-}" ]] || return 1
    for name in "$@"
    do
        bin_dir="${CONDA_PREFIX}/envs/${name}/bin"
        if [[ ! -d "$bin_dir" ]]
        then
            koopa::warning "Conda environment missing: '${bin_dir}'."
            return 1
        fi
        koopa::add_to_path_start "$bin_dir"
    done
    return 0
}

koopa::add_local_bins_to_path() { # {{{1
    # """
    # Add local build bins to PATH (e.g. '/usr/local').
    # @note Updated 2020-07-06.
    #
    # This will recurse through the local library and find 'bin/' subdirs.
    # Note: read '-a' flag doesn't work on macOS.
    # """
    local dir dirs
    koopa::assert_has_no_args "$#"
    koopa::add_to_path_start "$(koopa::make_prefix)/bin"
    readarray -t dirs <<< "$(koopa::find_local_bin_dirs)"
    for dir in "${dirs[@]}"
    do
        koopa::add_to_path_start "$dir"
    done
    return 0
}

koopa::reset_minimal_path() {
    # """
    # Reset 'PATH' to minimal system default.
    # @note Updated 2021-05-05.
    #
    # Particularly useful for building some programs from source on macOS.
    # """
    PATH='/usr/bin:/bin:/usr/sbin:/sbin'
    export PATH
    unset -v PKG_CONFIG_PATH
    return 0
}
