#!/usr/bin/env bash

koopa::brew_cask_outdated() { # {{{
    # """
    # List outdated Homebrew casks.
    # @note Updated 2020-07-03.
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
    local tmp_file x
    koopa::assert_has_no_args "$#"
    koopa::assert_is_installed brew
    tmp_file="$(koopa::tmp_file)"
    script -q "$tmp_file" brew cask outdated --greedy >/dev/null
    x="$(grep -v "(latest)" "$tmp_file")"
    [[ -n "$x" ]] && return 0
    koopa::print "$x"
    return 0
}

koopa::brew_outdated() { # {{{
    # """
    # Listed outdated Homebrew brews and casks, in a single call.
    # @note Updated 2020-07-01.
    # """
    koopa::assert_has_no_args "$#"
    koopa::h1 "Checking for outdated Homebrew formula."
    brew update &>/dev/null
    koopa::h2 "Brews"
    brew outdated
    koopa::h2 "Casks"
    koopa::brew_cask_outdated
    return 0
}

koopa::brew_update() { # {{{1
    # """
    # Updated outdated Homebrew brews and casks.
    # @note Updated 2020-07-01.
    #
    # Alternative approaches:
    # > brew list \
    # >     | xargs brew reinstall --force-bottle --cleanup \
    # >     || true
    # > brew cask outdated --greedy \
    # >     | xargs brew cask reinstall \
    # >     || true
    #
    # @seealso
    # Refer to useful discussion regarding '--greedy' flag.
    # https://discourse.brew.sh/t/brew-cask-outdated-greedy/3391
    # """
    local casks name_fancy
    koopa::assert_has_no_args "$#"
    koopa::assert_is_installed brew
    name_fancy="Homebrew"
    koopa::update_start "$name_fancy"
    brew analytics off
    brew update >/dev/null
    koopa::h2 "Updating brews."
    brew upgrade --force-bottle || true
    koopa::h2 "Updating casks."
    casks="$(koopa::brew_cask_outdated)"
    if [[ -n "$casks" ]]
    then
        koopa::info "${#casks[@]} outdated casks detected."
        koopa::print "${casks[@]}"
        koopa::print "${casks[@]}" \
            | cut -d " " -f 1 \
            | xargs brew cask reinstall \
            || true
    fi
    koopa::h2 "Running cleanup."
    brew cleanup -s || true
    rm -fr "$(brew --cache)"
    koopa::update_r_config
    koopa::update_success "$name_fancy"
    return 0
}
