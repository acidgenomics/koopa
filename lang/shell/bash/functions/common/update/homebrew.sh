#!/usr/bin/env bash

koopa::update_homebrew() { # {{{1
    # """
    # Updated outdated Homebrew brews and casks.
    # @note Updated 2020-12-17.
    #
    # Use of '--force-bottle' flag can be helpful, but not all brews have
    # bottles, so this can error.
    #
    # Alternative approaches:
    # > brew list \
    # >     | xargs brew reinstall --force-bottle --cleanup \
    # >     || true
    # > brew outdated --cask --greedy \
    # >     | xargs brew reinstall \
    # >     || true
    #
    # @seealso
    # - Refer to useful discussion regarding '--greedy' flag.
    # - https://discourse.brew.sh/t/brew-cask-outdated-greedy/3391
    # - https://github.com/Homebrew/brew/issues/9139
    # """
    local cask_flags casks name_fancy
    koopa::assert_has_no_args "$#"
    koopa::assert_is_installed brew
    koopa::assert_has_sudo
    export HOMEBREW_CASK_OPTS='--force --no-quarantine'
    name_fancy='Homebrew'
    koopa::update_start "$name_fancy"
    brew analytics off
    brew update >/dev/null
    koopa::h2 'Updating brews.'
    brew upgrade || true
    if koopa::is_macos
    then
        koopa::h2 'Updating casks.'
        readarray -t casks <<< "$(koopa::macos_brew_cask_outdated)"
        if koopa::is_array_non_empty "${casks[@]}"
        then
            koopa::info "${#casks[@]} outdated casks detected."
            koopa::print "${casks[@]}"
            for cask in "${casks[@]}"
            do
                cask="$(koopa::print "${cask[@]}" | cut -d ' ' -f 1)"
                case "$cask" in
                    docker)
                        cask='homebrew/cask/docker'
                        ;;
                    macvim)
                        cask='homebrew/cask/macvim'
                        ;;
                esac
                cask_flags=(
                    # --debug
                    # '--verbose'
                    '--force'
                    '--no-quarantine'
                )
                brew reinstall "${cask_flags[@]}" "$cask" || true
                if [[ "$cask" == 'r' ]]
                then
                    koopa::update_r_config
                fi
            done
        fi
    fi
    koopa::h2 'Running cleanup.'
    brew cleanup -s || true
    koopa::rm "$(brew --cache)"
    koopa::update_success "$name_fancy"
    return 0
}
