#!/usr/bin/env bash

update_prelude_emacs() { # {{{1
    # """
    # Update spacemacs non-interatively.
    # @note Updated 2021-11-23.
    #
    # Potentially useful: 'emacs --no-window-system'.
    #
    # How to update packages from command line:
    # > emacs \
    # >     --batch -l "${prefix}/init.el" \
    # >     --eval='(configuration-layer/update-packages t)'
    # """
    local dict
    koopa_assert_has_no_args "$#"
    declare -A dict=(
        [prefix]="${UPDATE_PREFIX:?}"
    )
    koopa_git_pull "${dict[prefix]}"
    return 0
}
