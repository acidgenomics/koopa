#!/usr/bin/env bash

koopa_app_json() {
    # """
    # Parse 'app.json' file using our internal Python JSON parser.
    # @note Updated 2023-12-11.
    #
    # @examples
    # koopa_app_json \
    #     --app-name='coreutils' \
    #     --key='bin'
    # """
    koopa_python_script 'app-json.py' "$@"
    return 0
}
