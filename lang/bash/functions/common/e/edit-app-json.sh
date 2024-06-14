#!/usr/bin/env bash

koopa_edit_app_json() {
    # """
    # Edit 'app.json' file with terminal editor.
    # @note Updated 2024-06-13.
    # """
    local -A app dict
    app['editor']="${EDITOR:-vim}"
    koopa_assert_is_installed "${app[@]}"
    dict['json_file']="$(koopa_koopa_prefix)/etc/koopa/app.json"
    koopa_assert_is_file "${dict['json_file']}"
    "${app['editor']}" "${dict['json_file']}"
    return 0
}
