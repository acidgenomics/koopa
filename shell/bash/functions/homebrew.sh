#!/usr/bin/env bash

_koopa_brew_cask_outdated() { # {{{
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
    _koopa_assert_has_no_args "$#"
    _koopa_assert_is_installed brew
    local tmp_file x
    tmp_file="$(_koopa_tmp_file)"
    script -q "$tmp_file" brew cask outdated --greedy >/dev/null
    x="$(grep -v "(latest)" "$tmp_file")"
    [[ -n "$x" ]] && return 0
    _koopa_print "$x"
    return 0
}

_koopa_brew_outdated() { # {{{
    # """
    # Listed outdated Homebrew brews and casks, in a single call.
    # @note Updated 2020-07-01.
    # """
    _koopa_assert_has_no_args "$#"
    _koopa_h1 "Checking for outdated Homebrew formula."
    brew update &>/dev/null
    _koopa_h2 "Brews"
    brew outdated
    _koopa_h2 "Casks"
    _koopa_brew_cask_outdated
    return 0
}

_koopa_brew_update() { # {{{1
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
    _koopa_assert_has_no_args "$#"
    _koopa_assert_is_installed brew
    local casks name_fancy
    name_fancy="Homebrew"
    _koopa_update_start "$name_fancy"
    brew analytics off
    brew update >/dev/null
    _koopa_h2 "Updating brews."
    brew upgrade --force-bottle || true
    _koopa_h2 "Updating casks."
    casks="$(_koopa_brew_cask_outdated)"
    if [[ -n "$casks" ]]
    then
        _koopa_info "${#casks[@]} outdated casks detected."
        _koopa_print "${casks[@]}"
        _koopa_print "${casks[@]}" \
            | cut -d " " -f 1 \
            | xargs brew cask reinstall \
            || true
    fi
    _koopa_h2 "Running cleanup."
    brew cleanup -s || true
    rm -fr "$(brew --cache)"
    _koopa_update_r_config
    _koopa_update_success "$name_fancy"
    return 0
}

