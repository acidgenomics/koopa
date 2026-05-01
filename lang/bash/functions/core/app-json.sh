#!/usr/bin/env bash

_koopa_app_json() {
    # """
    # Parse 'app.json' file using our internal Python JSON parser.
    # @note Updated 2023-12-11.
    #
    # @examples
    # _koopa_app_json \
    #     --app-name='coreutils' \
    #     --key='bin'
    # """
    "${KOOPA_PREFIX:?}/bin/koopa" internal app-json "$@"
    return 0
}
