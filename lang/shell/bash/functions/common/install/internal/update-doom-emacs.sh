#!/usr/bin/env bash

# FIXME This is now failing to locate Emacs...
# FIXME Consider adding this step:
# Also useful: rm -rf .emacs.d/.local/straight/build-*

# FIXME Need to change default branch to 'master' from 'develop'.

koopa:::update_doom_emacs() { # {{{1
    # """
    # Update Doom Emacs.
    # @note Updated 2021-11-22.
    #
    # @seealso
    # https://github.com/hlissner/doom-emacs/blob/develop/core/cli/upgrade.el
    # """
    local app
    koopa::assert_has_no_args "$#"
    declare -A app=(
        [doom]="$(koopa::locate_doom)"
        [emacs]="$(koopa::locate_emacs)"
    )
    koopa::add_to_path_start "$(koopa::dirname "${app[emacs]}")"
    "${app[doom]}" --yes upgrade --force
    "${app[doom]}" --yes sync
    return 0
}
