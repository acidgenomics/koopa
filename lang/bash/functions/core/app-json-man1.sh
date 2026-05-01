#!/usr/bin/env bash

_koopa_app_json_man1() {
    # """
    # Get 'man1' links from 'app.json' file.
    # @note Updated 2023-12-14.
    #
    # @examples
    # > _koopa_app_json_man1 'coreutils' 'binutils'
    # """
    local name
    _koopa_assert_has_args "$#"
    for name in "$@"
    do
        _koopa_app_json \
            --name="$name" \
            --key='man1'
    done
}
