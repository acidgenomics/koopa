#!/usr/bin/env bash

# NOTE On macOS, hitting this annoying warning when using GUI Emacs:
# > /System/Library/Frameworks/Ruby.framework/Versions/2.6/usr/lib/ruby/2.6.0/
# >   universal-darwin21/rbconfig.rb:230: warning: Insecure world writable dir
# >   /Applications/Emacs.app/Contents/MacOS in PATH, mode 040777

main() {
    # """
    # Update Doom Emacs.
    # @note Updated 2022-08-11.
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
    [[ -x "${app[doom]}" ]] || return 1
    [[ -x "${app[emacs]}" ]] || return 1
    koopa_add_to_path_start "$(koopa_dirname "${app[emacs]}")"
    "${app[doom]}" --force sync
    "${app[doom]}" --force upgrade
    "${app[doom]}" --force sync
    # > "${app[doom]}" --force doctor
    return 0
}
