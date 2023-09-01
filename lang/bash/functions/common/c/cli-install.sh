#!/usr/bin/env bash

koopa_cli_install() {
    # """
    # Parse user input to 'koopa install'.
    # @note Updated 2023-08-29.
    #
    # @examples
    # > koopa_cli_install --binary --reinstall --verbose 'tmux' 'vim'
    # > koopa_cli_install user 'doom-emacs' 'spacemacs'
    # """
    local -A dict
    local -a flags pos
    local app
    koopa_assert_has_args "$#"
    dict['allow_custom']=0
    dict['custom_enabled']=0
    dict['stem']='install'
    case "${1:-}" in
        '--all')
            shift 1
            koopa_install_all_apps "$@"
            return 0
            ;;
        '--all-binary')
            shift 1
            koopa_install_all_binary_apps "$@"
            return 0
            ;;
        'app')
            koopa_stop 'Unsupported command.'
            ;;
        'koopa')
            dict['allow_custom']=1
            ;;
    esac
    flags=()
    pos=()
    while (("$#"))
    do
        case "$1" in
            '--binary' | \
            '--push' | \
            '--reinstall' | \
            '--verbose')
                flags+=("$1")
                shift 1
                ;;
            '-'*)
                if [[ "${dict['allow_custom']}" -eq 1 ]]
                then
                    dict['custom_enabled']=1
                    pos+=("$1")
                    shift 1
                else
                    koopa_invalid_arg "$1"
                fi
                ;;
            *)
                pos+=("$1")
                shift 1
                ;;
        esac
    done
    [[ "${#pos[@]}" -gt 0 ]] && set -- "${pos[@]}"
    case "${1:-}" in
        'private' | \
        'system' | \
        'user')
            dict['stem']="${dict['stem']}-${1:?}"
            shift 1
            ;;
    esac
    koopa_assert_has_args "$#"
    if [[ "${dict['custom_enabled']}" -eq 1 ]]
    then
        dict['app']="${1:?}"
        shift 1
        dict['key']="${dict['stem']}-${dict['app']}"
        dict['fun']="$(koopa_which_function "${dict['key']}" || true)"
        if ! koopa_is_function "${dict['fun']}"
        then
            koopa_stop "Unsupported app: '${dict['app']}'."
        fi
        "${dict['fun']}" "$@"
        return 0
    fi
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
            "${dict2['fun']}" "${flags[@]:-}"
        else
            "${dict2['fun']}"
        fi
    done
    return 0
}
