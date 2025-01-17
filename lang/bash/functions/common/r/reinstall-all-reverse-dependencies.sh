#!/usr/bin/env bash

koopa_reinstall_all_revdeps() {
    # """
    # Reinstall an app and all of its reverse dependencies.
    # @note Updated 2023-03-30.
    #
    # We're intentionally allowing the passthrough of '--push' here, but the
    # ability to push a koopa binary is not required.
    #
    # @examples
    # > koopa_reinstall_all_revdeps --push 'node' 'python3.12'
    # """
    local -a flags pos
    local app_name
    koopa_assert_has_args "$#"
    flags=()
    pos=()
    while (("$#"))
    do
        case "$1" in
            # Key-value pairs --------------------------------------------------
            '--'*)
                flags+=("$1")
                shift 1
                ;;
            *)
                pos+=("$1")
                shift 1
                ;;
        esac
    done
    [[ "${#pos[@]}" -gt 0 ]] && set -- "${pos[@]}"
    koopa_assert_has_args "$#"
    for app_name in "$@"
    do
        local -a install_args revdeps
        install_args=()
        if koopa_is_array_non_empty "${flags[@]:-}"
        then
            install_args+=("${flags[@]}")
        fi
        install_args+=("$app_name")
        readarray -t revdeps <<< "$(koopa_app_reverse_dependencies "$app_name")"
        if koopa_is_array_non_empty "${revdeps[@]:-}"
        then
            install_args+=("${revdeps[@]}")
            koopa_dl \
                "${app_name} reverse dependencies" \
                "$(koopa_to_string "${revdeps[@]}")"
        else
            koopa_alert_note "'${app_name}' has no reverse dependencies."
        fi
        koopa_cli_reinstall "${install_args[@]}"
    done
    return 0
}
