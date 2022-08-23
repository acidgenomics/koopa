#!/usr/bin/env bash

koopa_app_json_man1() {
    # """
    # Get 'man1' links from 'app.json' file.
    # @note Updated 2022-08-23.
    #
    # @examples
    # > koopa_app_json_man1 'coreutils'
    # """
    koopa_assert_has_args_eq "$#" 1
    koopa_parse_app_json --app-name="${1:?}" --key='man1'
}
