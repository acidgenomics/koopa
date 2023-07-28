#!/usr/bin/env bash

koopa_cli_uninstall() {
    # """
    # Parse user input to 'koopa uninstall'.
    # @note Updated 2023-07-28.
    #
    # @seealso
    # > koopa_cli_uninstall 'tmux' 'vim'
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
    if [[ "${#pos[@]}" -gt 0 ]]
    then
        set -- "${pos[@]}"
    else
        set -- 'koopa'
    fi
    stem='uninstall'
    case "$1" in
        'private' | \
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
