#!/usr/bin/env bash

# NOTE On macOS, hitting this annoying warning when using GUI Emacs:
# > /System/Library/Frameworks/Ruby.framework/Versions/2.6/usr/lib/ruby/2.6.0/
# >   universal-darwin21/rbconfig.rb:230: warning: Insecure world writable dir
# >   /Applications/Emacs.app/Contents/MacOS in PATH, mode 040777

main() { # {{{1
    # """
    # Update Doom Emacs.
    # @note Updated 2022-04-19.
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
