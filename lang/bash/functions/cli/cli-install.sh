#!/usr/bin/env bash

_koopa_cli_install() {
    # """
    # Parse user input to 'koopa install'.
    # @note Updated 2024-07-12.
    #
    # @examples
    # > _koopa_cli_install --reinstall --verbose 'tmux' 'vim'
    # > _koopa_cli_install user 'doom-emacs' 'spacemacs'
    # """
    local -A dict
    local -a flags pos
    local app
    _koopa_assert_has_args "$#"
    dict['stem']='install'
    case "${1:-}" in
        'koopa')
            shift 1
            _koopa_install_koopa "$@"
            return 0
            ;;
        'private' | 'system' | 'user')
            dict['stem']="${dict['stem']}-${1:?}"
            shift 1
            ;;
        'app' | 'shared-apps')
            _koopa_stop 'Unsupported command.'
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
                _koopa_invalid_arg "$1"
                ;;
            *)
                pos+=("$1")
                shift 1
                ;;
        esac
    done
    [[ "${#pos[@]}" -gt 0 ]] && set -- "${pos[@]}"
    _koopa_assert_has_args "$#"
    for app in "$@"
    do
        local -A dict2
        dict2['app']="$app"
        dict2['key']="${dict['stem']}-${dict2['app']}"
        dict2['fun']="$(_koopa_which_function "${dict2['key']}" || true)"
        if ! _koopa_is_function "${dict2['fun']}"
        then
            _koopa_stop "Unsupported app: '${dict2['app']}'."
        fi
        if _koopa_is_array_non_empty "${flags[@]:-}"
        then
            "${dict2['fun']}" "${flags[@]}"
        else
            "${dict2['fun']}"
        fi
    done
    return 0
}
