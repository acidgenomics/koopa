#!/usr/bin/env bash

koopa_configure_user_chemacs() {
    # """
    # Configure chemacs for current user.
    # @note Updated 2022-12-05.
    # """
    local -A dict
    koopa_assert_has_args_le "$#" 1
    dict['source_prefix']="${1:-}"
    dict['opt_prefix']="$(koopa_opt_prefix)"
    dict['target_prefix']="${HOME:?}/.emacs.d"
    if [[ -z "${dict['source_prefix']}" ]]
    then
        dict['source_prefix']="${dict['opt_prefix']}/chemacs"
    fi
    koopa_assert_is_dir "${dict['source_prefix']}"
    dict['source_prefix']="$(koopa_realpath "${dict['source_prefix']}")"
    koopa_ln "${dict['source_prefix']}" "${dict['target_prefix']}"
    return 0
}
