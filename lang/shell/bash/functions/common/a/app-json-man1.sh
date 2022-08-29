#!/usr/bin/env bash

koopa_app_json_man1() {
    # """
    # Get 'man1' links from 'app.json' file.
    # @note Updated 2022-08-23.
    #
    # @examples
    # > koopa_app_json_man1 'coreutils' 'binutils'
    # """
    local app_name
    koopa_assert_has_args "$#"
    for app_name in "$@"
    do
        koopa_parse_app_json \
            --app-name="$app_name" \
            --key='man1'
    done
}
