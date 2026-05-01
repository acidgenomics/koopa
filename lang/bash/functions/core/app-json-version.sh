#!/usr/bin/env bash

_koopa_app_json_version() {
    # """
    # Get app version from 'app.json' file.
    # @note Updated 2023-12-14.
    #
    # @examples
    # > _koopa_app_json_version 'coreutils' 'binutils'
    # # 9.1
    # # 2.38
    # """
    local name
    _koopa_assert_has_args "$#"
    for name in "$@"
    do
        _koopa_app_json \
            --name="$name" \
            --key='version'
    done
}
