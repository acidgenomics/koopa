#!/usr/bin/env bash

koopa::brewfile() { # {{{1
    # """
    # Homebrew Bundle Brewfile path.
    # @note Updated 2020-11-13.
    # """
    local file os
    if koopa::is_macos
    then
        os='macos'
    else
        os='linux'
    fi
    file="$(koopa::dotfiles_prefix)/os/${os}/app/homebrew/brewfile"
    [[ -f "$file" ]] || return 0
    koopa::print "$file"
    return 0
}

koopa::brew_outdated() { # {{{
    # """
    # Listed outdated Homebrew brews and casks, in a single call.
    # @note Updated 2020-07-01.
    # """
    koopa::assert_has_no_args "$#"
    koopa::h1 'Checking for outdated Homebrew formula.'
    brew update &>/dev/null
    koopa::h2 'Brews'
    brew outdated
    if koopa::is_macos
    then
        koopa::h2 'Casks'
        koopa::macos_brew_cask_outdated
    fi
    return 0
}
