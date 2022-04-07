#!/usr/bin/env bash

main() { # {{{1
    # """
    # Update Doom Emacs.
    # @note Updated 2022-01-26.
    #
    # @seealso
    # https://github.com/hlissner/doom-emacs/blob/develop/core/cli/upgrade.el
    # """
    local app
    koopa_assert_has_no_args "$#"
    declare -A app=(
        [doom]="$(koopa_locate_doom)"
        [emacs]="$(koopa_locate_emacs)"
    )
    koopa_add_to_path_start "$(koopa_dirname "${app[emacs]}")"
    "${app[doom]}" --yes upgrade --force
    "${app[doom]}" --yes sync
    # > "${app[doom]}" --yes doctor
    return 0
}
