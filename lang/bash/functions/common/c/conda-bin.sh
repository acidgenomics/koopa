#!/usr/bin/env bash

koopa_conda_bin() {
    # """
    # Parse conda JSON metadata for files to link in 'bin'.
    # @note Updated 2023-12-11.
    #
    # @examples
    # koopa_conda_bin \
    #     /opt/koopa/opt/salmon/libexec/conda-meta/salmon-*.json
    # """
    local cmd file
    koopa_assert_has_args_eq "$#" 1
    file="${1:?}"
    koopa_assert_is_file "$file"
    cmd="$(koopa_python_prefix)/conda-bin.py"
    koopa_assert_is_executable "$cmd"
    "$cmd" "$file"
    return 0
}
