#!/usr/bin/env bash

koopa_parse_conda_meta_json() {
    # """
    # Parse conda meta file using our internal Python JSON parser.
    # @note Updated 2023-03-20.
    #
    # @examples
    # koopa_parse_conda_meta_json \
    #     /opt/koopa/opt/salmon/libexec/conda-meta/salmon-*.json
    # """
    local cmd file
    koopa_assert_has_args_eq "$#" 1
    file="${1:?}"
    koopa_assert_is_file "$file"
    cmd="$(koopa_koopa_prefix)/lang/python/conda-meta-json.py"
    koopa_assert_is_executable "$cmd"
    "$cmd" "$file"
    return 0
}
