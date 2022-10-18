#!/usr/bin/env bash

koopa_app_json_revdeps() {
    # """
    # Get reverse dependencies from 'app.json' file.
    # @note Updated 2022-10-18.
    #
    # @examples
    # > koopa_app_json_revdeps 'python'
    # """
    local app_name
    koopa_assert_has_args "$#"
    for app_name in "$@"
    do
        koopa_parse_app_json \
            --app-name="$app_name" \
            --key='reverse_dependencies'
    done
    return 0
}
