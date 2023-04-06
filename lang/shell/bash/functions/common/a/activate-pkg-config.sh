#!/usr/bin/env bash

koopa_activate_pkg_config() {
    # """
    # Force add to start of 'PKG_CONFIG_PATH' using 'pc_path' variable
    # lookup from 'pkg-config' program.
    # @note Updated 2022-09-04.
    #
    # @examples
    # > koopa_activate_pkg_config '/opt/koopa/bin/pkg-config'
    # > echo "$PKG_CONFIG_PATH"
    # """
    local app
    koopa_assert_has_args "$#"
    PKG_CONFIG_PATH="${PKG_CONFIG_PATH:-}"
    for app in "$@"
    do
        local str
        [[ -x "$app" ]] || continue
        str="$("$app" --variable 'pc_path' 'pkg-config')"
        PKG_CONFIG_PATH="$( \
            koopa_add_to_path_string_start "$PKG_CONFIG_PATH" "$str" \
        )"
    done
    export PKG_CONFIG_PATH
    return 0
}
