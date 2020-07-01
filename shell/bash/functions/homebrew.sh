#!/usr/bin/env bash

_koopa_brew_cask_outdated() { # {{{
    # """
    # List outdated Homebrew casks.
    # @note Updated 2020-07-01.
    #
    # Need help with capturing output:
    # - https://stackoverflow.com/questions/58344963/
    # - https://unix.stackexchange.com/questions/253101/
    #
    # @seealso
    # - brew leaves
    # - brew deps --installed --tree
    # - brew list --versions
    # - brew info
    # """
    [[ "$#" -eq 0 ]] || return 1
    _koopa_is_installed brew || return 1
    local tmp_file x
    tmp_file="$(_koopa_tmp_file)"
    script -q "$tmp_file" brew cask outdated --greedy >/dev/null
    x="$(grep -v "(latest)" "$tmp_file")"
    [[ -n "$x" ]] || return 1
    _koopa_print "$x"
    return 0
}

_koopa_brew_outdated() { # {{{
    # """
    # Listed outdated Homebrew brews and casks, in a single call.
    # @note Updated 2020-07-01.
    # """
    [[ "$#" -eq 0 ]] || return 1
    _koopa_h1 "Checking for outdated Homebrew formula."
    brew update &>/dev/null
    _koopa_h2 "Brews"
    brew outdated
    _koopa_h2 "Casks"
    _koopa_brew_cask_outdated
    return 0
}
