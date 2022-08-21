#!/usr/bin/env bash

main() {
    # """
    # Update Doom Emacs.
    # @note Updated 2022-08-11.
    #
    # NOTE Consider warning or erroring if user hasn't set up doom configuration
    # using our dotfiles configuration.
    #
    # @seealso
    # https://github.com/hlissner/doom-emacs/blob/develop/core/cli/upgrade.el
    # """
    local app
    koopa_assert_has_no_args "$#"
    declare -A app=(
        ['doom']="$(koopa_locate_doom)"
        ['emacs']="$(koopa_locate_emacs)"
    )
    [[ -x "${app['doom']}" ]] || return 1
    [[ -x "${app['emacs']}" ]] || return 1
    koopa_add_to_path_start "$(koopa_dirname "${app['emacs']}")"
    # > "${app['doom']}" --force sync
    "${app['doom']}" --force upgrade
    "${app['doom']}" --force sync
    # > "${app['doom']}" --force doctor
    return 0
}
