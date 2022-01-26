#!/usr/bin/env bash

koopa:::update_spacemacs() { # {{{1
    # """
    # Update Spacemacs.
    # @note Updated 2021-11-23.
    #
    # How to update packages from the command line in chemacs2 config:
    # > emacs \
    # >     --no-window-system \
    # >     --with-profile 'spacemacs' \
    # >     --eval='(configuration-layer/update-packages t)'
    # """
    local dict
    koopa::assert_has_no_args "$#"
    declare -A dict=(
        [prefix]="${UPDATE_PREFIX:?}"
    )
    koopa::git_pull "${dict[prefix]}"
    return 0
}
