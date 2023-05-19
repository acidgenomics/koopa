#!/usr/bin/env bash

main() {
    # """
    # Configure chemacs for current user.
    # @note Updated 2023-05-12.
    # """
    local -A dict
    koopa_assert_has_no_args "$#"
    dict['source']="$(koopa_opt_prefix)/chemacs"
    dict['target']="${HOME:?}/.emacs.d"
    koopa_assert_is_dir "${dict['source']}"
    koopa_ln "${dict['source']}" "${dict['target']}"
    return 0
}
