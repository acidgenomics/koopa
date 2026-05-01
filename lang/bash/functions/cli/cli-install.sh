#!/usr/bin/env bash

_koopa_cli_install() {
    # """
    # Parse user input to 'koopa install'.
    # @note Updated 2026-05-01.
    #
    # @examples
    # > _koopa_cli_install --reinstall --verbose 'tmux' 'vim'
    # > _koopa_cli_install system 'homebrew'
    # """
    local -A dict
    local -a flags pos
    local app
    _koopa_assert_has_args "$#"
    dict['mode']=''
    case "${1:-}" in
        'koopa')
            shift 1
            _koopa_install_koopa "$@"
            return 0
            ;;
        'private')
            dict['mode']='private'
            shift 1
            ;;
        'system')
            dict['mode']='system'
            shift 1
            ;;
        'user')
            dict['mode']='user'
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
        local -a install_args
        install_args=("--name=${app}")
        case "${dict['mode']}" in
            'private')
                install_args+=('--private')
                ;;
            'system')
                install_args+=('--system')
                ;;
            'user')
                install_args+=('--user')
                ;;
        esac
        _koopa_install_app "${install_args[@]}" "${flags[@]:-}"
    done
    return 0
}
