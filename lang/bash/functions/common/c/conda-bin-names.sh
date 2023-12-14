#!/usr/bin/env bash

koopa_conda_bin_names() {
    # """
    # Parse conda JSON metadata for files to link in 'bin'.
    # @note Updated 2023-12-11.
    #
    # @examples
    # koopa_conda_bin \
    #     /opt/koopa/opt/salmon/libexec/conda-meta/salmon-*.json
    # """
    koopa_assert_has_args_eq "$#" 1
    koopa_python_script 'conda-bin-names.py' "$@"
    return 0
}
