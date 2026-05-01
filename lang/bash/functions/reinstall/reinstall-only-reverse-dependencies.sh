#!/usr/bin/env bash

_koopa_reinstall_only_revdeps() {
    # """
    # Reinstall only the reverse dependencies of an app.
    # @note Updated 2023-03-30.
    #
    # We're intentionally allowing the passthrough of '--push' here, but the
    # ability to push a koopa binary is not required.
    #
    # @examples
    # > _koopa_reinstall_only_revdeps --push 'node' 'python3.13'
    # """
    local -a flags pos
    local app_name
    _koopa_assert_has_args "$#"
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
    _koopa_assert_has_args "$#"
    for app_name in "$@"
    do
        local -a install_args revdeps
        install_args=()
        if _koopa_is_array_non_empty "${flags[@]:-}"
        then
            install_args+=("${flags[@]}")
        fi
        readarray -t revdeps <<< "$(_koopa_app_reverse_dependencies "$app_name")"
        if _koopa_assert_is_array_non_empty "${revdeps[@]}"
        then
            install_args+=("${revdeps[@]}")
            _koopa_dl \
                "${app_name} reverse dependencies" \
                "$(_koopa_to_string "${revdeps[@]}")"
        else
            _koopa_stop "'${app_name}' has no reverse dependencies."
        fi
        _koopa_cli_reinstall "${install_args[@]}"
    done
    return 0
}
