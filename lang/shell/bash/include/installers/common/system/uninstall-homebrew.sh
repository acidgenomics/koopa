#!/usr/bin/env bash

main() { # {{{1
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
    koopa_assert_has_no_args "$#"
    declare -A app=(
        [yes]="$(koopa_locate_yes)"
    )
    declare -A dict=(
        [user]="$(koopa_user)"
    )
    dict[file]='uninstall.sh'
    dict[url]="https://raw.githubusercontent.com/Homebrew/install/\
master/${dict[file]}"
    if koopa_is_macos
    then
        koopa_alert 'Changing default shell to system Zsh.'
        chsh -s '/bin/zsh' "${dict[user]}"
    fi
    koopa_download "${dict[url]}" "${dict[file]}"
    koopa_chmod 'u+x' "${dict[file]}"
    "${app[yes]}" | "./${dict[file]}" || true
    return 0
}
