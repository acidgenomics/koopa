#!/usr/bin/env bash

koopa:::update_doom_emacs() { # {{{1
    # """
    # Update Doom Emacs.
    # @note Updated 2022-01-26.
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
    # > "${app[doom]}" --yes doctor
    return 0
}
