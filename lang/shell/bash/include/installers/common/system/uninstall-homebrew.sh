#!/usr/bin/env bash

# Here's how to remove all brew formula:
# https://apple.stackexchange.com/questions/198623/
# > while [[ "$(brew list | wc -l)" -ne 0 ]]
# > do
# >     for brew in "$(brew list)"
# >     do
# >         brew uninstall --force --ignore-dependencies "$brew"
# >     done
# > done

main() { # {{{1
    # """
    # Uninstall Homebrew.
    # @note Updated 2022-04-08.
    #
    # macOS Catalina now uses Zsh instead of Bash by default.
    #
    # @seealso
    # - https://docs.brew.sh/FAQ
    # """
    local app dict
    koopa_assert_has_no_args "$#"
    declare -A app=(
        [sudo]="$(koopa_locate_sudo)"
        [yes]="$(koopa_locate_yes)"
    )
    declare -A dict=(
        [user]="$(koopa_user)"
    )
    dict[file]='uninstall.sh'
    dict[url]="https://raw.githubusercontent.com/Homebrew/install/\
master/${dict[file]}"
    # Important! Homebrew uninstaller will currently attempt to delete the
    # parent directory containing 'brew', so make sure we remove our symlink
    # in koopa first.
    koopa_unlink_in_bin 'brew'
    # > if koopa_is_macos
    # > then
    # >     koopa_alert 'Changing default shell to system Zsh.'
    # >     chsh -s '/bin/zsh' "${dict[user]}"
    # > fi
    koopa_download "${dict[url]}" "${dict[file]}"
    koopa_chmod 'u+x' "${dict[file]}"
    "${app[sudo]}" -v
    "${app[yes]}" | "./${dict[file]}" || true
    if koopa_is_linux
    then
        if [[ -d '/home/linuxbrew' ]]
        then
            koopa_rm --sudo '/home/linuxbrew'
        fi
    elif koopa_is_macos
    then
        koopa_macos_unlink_homebrew
    fi
    return 0
}
