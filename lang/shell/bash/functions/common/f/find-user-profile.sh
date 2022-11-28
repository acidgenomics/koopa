#!/usr/bin/env bash

# FIXME This isn't finding zshrc as expected during koopa install on macOS.
# Need to rethink the handling here in koopa_shell_name subcall?

koopa_find_user_profile() {
    # """
    # Find current user's shell profile configuration file.
    # @note Updated 2022-02-03.
    # """
    local dict
    koopa_assert_has_no_args "$#"
    declare -A dict=(
        ['shell']="$(koopa_shell_name)"
    )
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
    koopa_print "${dict['file']}"
    return 0
}
