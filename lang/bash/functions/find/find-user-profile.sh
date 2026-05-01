#!/usr/bin/env bash

_koopa_find_user_profile() {
    # """
    # Find current user's shell profile configuration file.
    # @note Updated 2022-11-28.
    # """
    local -A dict
    _koopa_assert_has_no_args "$#"
    dict['shell']="$(_koopa_default_shell_name)"
    case "${dict['shell']}" in
        'bash')
            dict['file']="${HOME}/.bashrc"
            ;;
        'zsh')
            dict['file']="${HOME}/.zshrc"
            ;;
        *)
            dict['file']="${HOME}/.profile"
            ;;
    esac
    [[ -n "${dict['file']}" ]] || return 1
    _koopa_print "${dict['file']}"
    return 0
}
