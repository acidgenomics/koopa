#!/usr/bin/env bash

main() {
    # """
    # Update Doom Emacs.
    # @note Updated 2022-09-16.
    #
    # NOTE Consider warning or erroring if user hasn't set up doom configuration
    # using our dotfiles configuration.
    #
    # @seealso
    # https://github.com/hlissner/doom-emacs/blob/develop/core/cli/upgrade.el
    # """
    local app
    koopa_assert_has_no_args "$#"
    declare -A app
    app['doom']="$(koopa_locate_doom)"
    if koopa_is_macos
    then
        app['emacs']="$(koopa_macos_emacs)"
    else
        app['emacs']="$(koopa_locate_emacs)"
    fi
    [[ -x "${app['doom']}" ]] || return 1
    [[ -x "${app['emacs']}" ]] || return 1
    koopa_add_to_path_start "$(koopa_dirname "${app['emacs']}")"
    # > "${app['doom']}" sync
    "${app['doom']}" upgrade
    "${app['doom']}" sync
    # > "${app['doom']}" doctor
    return 0
}
