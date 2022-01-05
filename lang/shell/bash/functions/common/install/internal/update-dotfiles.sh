#!/usr/bin/env bash

# FIXME This is now erroring:
# /opt/koopa/bin/../lang/shell/bash/include/header.sh: line 114: activate: unbound variable
# /opt/koopa/opt/dotfiles/install: line 70: : No such file or directory

koopa:::update_dotfiles() { # {{{1
    # """
    # Update dotfiles repo and run install script, if defined.
    # @note Updated 2021-11-24.
    # """
    local app dict
    koopa::assert_has_no_args "$#"
    declare -A app=(
        [bash]="$(koopa::locate_bash)"
    )
    declare -A dict=(
        [prefix]="${UPDATE_PREFIX:?}"
    )
    dict[script]="${dict[prefix]}/install"
    koopa::assert_is_file "${dict[script]}"
    koopa::git_reset "${dict[prefix]}"
    koopa::git_pull "${dict[prefix]}"
    "${app[bash]}" "${dict[script]}"
    return 0
}
