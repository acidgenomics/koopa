#!/usr/bin/env bash

koopa_cli_configure() {
    # """
    # Parse user input to 'koopa configure'.
    # @note Updated 2023-05-14.
    #
    # @examples
    # > koopa_cli_configure 'julia' 'r'
    # """
    local -a flags pos
    local app stem
    flags=()
    pos=()
    while (("$#"))
    do
        case "$1" in
            '--verbose')
                flags+=("$1")
                shift 1
                ;;
            '-'*)
                koopa_invalid_arg "$1"
                ;;
            *)
                pos+=("$1")
                shift 1
                ;;
        esac
    done
    [[ "${#pos[@]}" -gt 0 ]] && set -- "${pos[@]}"
    stem='configure'
    case "$1" in
        'system' | \
        'user')
            stem="${stem}-${1}"
            shift 1
            ;;
    esac
    koopa_assert_has_args "$#"
    for app in "$@"
    do
        local -A dict
        dict['key']="${stem}-${app}"
        dict['fun']="$(koopa_which_function "${dict['key']}" || true)"
        if ! koopa_is_function "${dict['fun']}"
        then
            koopa_stop "Unsupported app: '${app}'."
        fi
        if koopa_is_array_non_empty "${flags[@]:-}"
        then
            "${dict['fun']}" "${flags[@]:-}"
        else
            "${dict['fun']}"
        fi
    done
    return 0
}
