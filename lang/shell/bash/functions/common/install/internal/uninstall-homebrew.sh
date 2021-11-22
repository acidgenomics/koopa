#!/usr/bin/env bash

koopa:::uninstall_homebrew() { # {{{1
    # """
    # Uninstall Homebrew.
    # @note Updated 2021-11-22.
    #
    # macOS Catalina now uses Zsh instead of Bash by default.
    #
    # @seealso
    # - https://docs.brew.sh/FAQ
    # """
    local app dict
    koopa::assert_is_admin
    declare -A app=(
        [yes]="$(koopa::locate_yes)"
    )
    declare -A dict=(
        [user]="$(koopa::user)"
    )
    dict[file]='uninstall.sh'
    dict[url]="https://raw.githubusercontent.com/Homebrew/install/\
master/${dict[file]}"
    if koopa::is_macos
    then
        koopa::alert 'Changing default shell to system Zsh.'
        chsh -s '/bin/zsh' "${dict[user]}"
    fi
    koopa::download "${dict[url]}" "${dict[file]}"
    koopa::chmod 'u+x' "${dict[file]}"
    "${app[yes]}" | "./${dict[file]}" || true
    return 0
}
