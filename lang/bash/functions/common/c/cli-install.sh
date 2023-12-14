#!/usr/bin/env bash

koopa_cli_install() {
    # """
    # Parse user input to 'koopa install'.
    # @note Updated 2023-12-11.
    #
    # @examples
    # > koopa_cli_install --reinstall --verbose 'tmux' 'vim'
    # > koopa_cli_install user 'doom-emacs' 'spacemacs'
    # """
    local -A dict
    local -a flags pos
    local app
    koopa_assert_has_args "$#"
    dict['stem']='install'
    case "${1:-}" in
        'all')
            shift 1
            case "${1:-}" in
                'default' | 'supported')
                    dict['fun']="koopa_install_all_${1:?}"
                    koopa_assert_is_function "${dict['fun']}"
                    shift 1
                    "${dict['fun']}" "$@"
                    return 0
                    ;;
                *)
                    koopa_stop 'Unsupported mode.'
                    ;;
                esac
            ;;
        'koopa')
            shift 1
            koopa_install_koopa "$@"
            return 0
            ;;
        'private' | 'system' | 'user')
            dict['stem']="${dict['stem']}-${1:?}"
            shift 1
            ;;
        'app' | 'shared-apps')
            koopa_stop 'Unsupported command.'
            ;;
        '--all')
            koopa_defunct 'koopa install all default'
            ;;
    esac
    flags=()
    pos=()
    while (("$#"))
    do
        case "$1" in
            '--bootstrap' | \
            '--reinstall' | \
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
    koopa_assert_has_args "$#"
    for app in "$@"
    do
        local -A dict2
        dict2['app']="$app"
        dict2['key']="${dict['stem']}-${dict2['app']}"
        dict2['fun']="$(koopa_which_function "${dict2['key']}" || true)"
        if ! koopa_is_function "${dict2['fun']}"
        then
            koopa_stop "Unsupported app: '${dict2['app']}'."
        fi
        if koopa_is_array_non_empty "${flags[@]:-}"
        then
            "${dict2['fun']}" "${flags[@]}"
        else
            "${dict2['fun']}"
        fi
    done
    return 0
}
