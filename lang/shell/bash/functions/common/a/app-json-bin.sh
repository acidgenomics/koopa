#!/usr/bin/env bash

koopa_app_json_bin() {
    # """
    # Get 'bin' links from 'app.json' file.
    # @note Updated 2022-08-23.
    #
    # @examples
    # > koopa_app_json_bin 'coreutils'
    # """
    koopa_assert_has_args_eq "$#" 1
    koopa_parse_app_json --app-name="${1:?}" --key='bin'
}
