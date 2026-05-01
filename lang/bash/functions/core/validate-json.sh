#!/usr/bin/env bash

_koopa_validate_json() {
    # """
    # Validate that a JSON file doesn't contain any formatting errors.
    # @note Updated 2025-08-21.
    #
    # @examples
    # _koopa_validate_json 'app.json'
    # """
    local -A app dict
    _koopa_assert_has_args_eq "$#" 1
    app['python']="$(_koopa_locate_python)"
    dict['file']="${1:?}"
    "${app['python']}" -m 'json.tool' "${dict['file']}" >/dev/null
}
