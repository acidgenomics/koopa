#!/usr/bin/env bash

koopa_add_to_pkg_config_path() {
    # """
    # Force add to start of 'PKG_CONFIG_PATH'.
    # @note Updated 2022-04-21.
    # """
    local dir
    koopa_assert_has_args "$#"
    PKG_CONFIG_PATH="${PKG_CONFIG_PATH:-}"
    for dir in "$@"
    do
        [[ -d "$dir" ]] || continue
        PKG_CONFIG_PATH="$( \
            __koopa_add_to_path_string_start "$PKG_CONFIG_PATH" "$dir" \
        )"
    done
    export PKG_CONFIG_PATH
    return 0
}
