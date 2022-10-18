#!/usr/bin/env bash

koopa_reinstall_all_revdeps() {
    # """
    # Reinstall (and push) all reverse dependencies.
    # @note Updated 2022-10-18.
    #
    # @examples
    # > koopa_reinstall_all_revdeps 'python'
    # """
    local app_names install_args revdeps
    koopa_assert_has_args "$#"
    app_names=("$@")
    readarray -t revdeps <<< "$(koopa_app_json_revdeps "${app_names[@]}")"
    koopa_assert_is_array_non_empty "${revdeps[@]}"
    install_args=()
    koopa_can_install_binary && install_args+=('--push')
    install_args+=("${app_names[@]}" "${revdeps[@]}")
    koopa_cli_reinstall "${install_args[@]}"
    return 0
}
