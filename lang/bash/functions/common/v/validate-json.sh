#!/usr/bin/env bash

koopa_validate_json() {
    # """
    # Validate that a JSON file doesn't contain any formatting errors.
    # @note Updated 2023-02-13.
    #
    # @examples
    # koopa_validate_json 'app.json'
    # """
    local -A app dict
    koopa_assert_has_args_eq "$#" 1
    app['python']="$(koopa_locate_python312)"
    dict['file']="${1:?}"
    "${app['python']}" -m 'json.tool' "${dict['file']}" >/dev/null
}
