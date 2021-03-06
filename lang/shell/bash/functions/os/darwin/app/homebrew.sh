#!/usr/bin/env bash

koopa::macos_brew_cask_outdated() { # {{{
    # """
    # List outdated Homebrew casks.
    # @note Updated 2020-11-12.
    #
    # Need help with capturing output:
    # - https://stackoverflow.com/questions/58344963/
    # - https://unix.stackexchange.com/questions/253101/
    #
    # Syntax changed from 'brew cask outdated' to 'brew outdated --cask' in
    # 2020-09.
    #
    # @seealso
    # - brew leaves
    # - brew deps --installed --tree
    # - brew list --versions
    # - brew info
    # """
    local tmp_file x
    koopa::assert_has_no_args "$#"
    koopa::assert_is_macos
    koopa::assert_is_installed brew
    tmp_file="$(koopa::tmp_file)"
    script -q "$tmp_file" brew outdated --cask --greedy >/dev/null
    x="$(grep -v '(latest)' "$tmp_file")"
    [[ -n "$x" ]] || return 0
    koopa::print "$x"
    return 0
}

koopa::macos_brew_cask_quarantine_fix() { # {{{1
    # """
    # Homebrew cask fix for macOS quarantine.
    # @note Updated 2020-11-12.
    # """
    koopa::assert_has_no_args "$#"
    koopa::assert_is_macos
    koopa::assert_has_sudo
    sudo xattr -r -d com.apple.quarantine /Applications/*.app
    return 0
}
