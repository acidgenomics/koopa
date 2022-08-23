#!/usr/bin/env bash

koopa_app_json_version() {
    # """
    # Get app version from 'app.json' file.
    # @note Updated 2022-08-23.
    #
    # @examples
    # > koopa_app_json_version 'coreutils'
    # """
    koopa_assert_has_args_eq "$#" 1
    koopa_parse_app_json --app-name="${1:?}" --key='version'
}
