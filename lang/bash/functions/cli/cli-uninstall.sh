#!/usr/bin/env bash

_koopa_cli_uninstall() {
    # """
    # Parse user input to 'koopa uninstall'.
    # @note Updated 2026-05-01.
    #
    # @seealso
    # > _koopa_cli_uninstall 'tmux' 'vim'
    # """
    local -A dict
    local -a flags pos
    local app
    dict['mode']=''
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
                _koopa_invalid_arg "$1"
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
    case "$1" in
        'koopa')
            shift 1
            _koopa_uninstall_koopa "$@"
            return 0
            ;;
        'private' | \
        'system' | \
        'user')
            dict['mode']="${1}"
            shift 1
            ;;
    esac
    _koopa_assert_has_args "$#"
    for app in "$@"
    do
        local -a uninstall_args
        uninstall_args=("--name=${app}")
        case "${dict['mode']}" in
            'system')
                uninstall_args+=('--system')
                ;;
            'user')
                uninstall_args+=('--user')
                ;;
        esac
        _koopa_uninstall_app "${uninstall_args[@]}" "${flags[@]:-}"
    done
    return 0
}
