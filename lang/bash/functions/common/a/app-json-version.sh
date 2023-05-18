#!/usr/bin/env bash

koopa_app_json_version() {
    # """
    # Get app version from 'app.json' file.
    # @note Updated 2023-03-30.
    #
    # @examples
    # > koopa_app_json_version 'coreutils' 'binutils'
    # # 9.1
    # # 2.38
    # """
    local app_name
    koopa_assert_has_args "$#"
    for app_name in "$@"
    do
        koopa_app_json \
            --app-name="$app_name" \
            --key='version'
    done
}
