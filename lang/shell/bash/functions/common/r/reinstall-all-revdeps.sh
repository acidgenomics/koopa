#!/usr/bin/env bash

koopa_reinstall_all_revdeps() {
    # """
    # Reinstall (and push) all reverse dependencies.
    # @note Updated 2022-10-18.
    #
    # @examples
    # > koopa_reinstall_all_revdeps 'python'
    # """
    local app_names
    koopa_assert_has_args "$#"
    koopa_can_install_binary || return 1
    readarray -t app_names <<< "$(koopa_app_json_revdeps "$@")"
    koopa_assert_is_array_non_empty "${app_names[@]}"
    koopa_cli_reinstall --push "${app_names[@]}"
    return 0
}
