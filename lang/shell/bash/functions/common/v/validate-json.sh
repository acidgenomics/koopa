#!/usr/bin/env bash

koopa_validate_json() {
    # """
    # Validate that a JSON file doesn't contain any formatting errors.
    # @note Updated 2022-08-23.
    #
    # @examples
    # koopa_validate_json '/opt/koopa/include/app.json'
    # """
    local app dict
    declare -A app dict
    koopa_assert_has_args_eq "$#" 1
    app['python']="$(koopa_locate_python)"
    dict['file']="${1:?}"
    "${app['python']}" -m 'json.tool' "${dict['file']}" >/dev/null
}
