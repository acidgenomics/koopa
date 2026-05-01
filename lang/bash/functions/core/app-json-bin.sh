#!/usr/bin/env bash

_koopa_app_json_bin() {
    # """
    # Get 'bin' links from 'app.json' file.
    # @note Updated 2023-12-14.
    #
    # @examples
    # > _koopa_app_json_bin 'coreutils' 'binutils'
    # """
    local name
    _koopa_assert_has_args "$#"
    for name in "$@"
    do
        _koopa_app_json \
            --name="$name" \
            --key='bin'
    done
}
