#!/usr/bin/env bash

# FIXME Need to locate grep here if we use the old approach.
koopa::macos_brew_cask_outdated() { # {{{
    # """
    # List outdated Homebrew casks.
    # @note Updated 2021-04-22.
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
    local keep_latest tmp_file x
    koopa::assert_has_no_args "$#"
    koopa::assert_is_macos
    koopa::assert_is_installed 'brew'
    # Whether we want to keep unversioned 'latest' casks returned with
    # '--greedy'. This tends to include font casks and the Google Cloud SDK,
    # which are annoying to have reinstall with each update, so disabling
    # here by default.
    keep_latest=0
    # This approach keeps the version information, which we can parse.
    tmp_file="$(koopa::tmp_file)"
    script -q "$tmp_file" brew outdated --cask --greedy >/dev/null
    if [[ "$keep_latest" -eq 1 ]]
    then
        x="$(cut -d ' ' -f 1 < "$tmp_file")"
    else
        # FIXME Rework using 'koopa::grep'.
        x="$( \
            grep -v '(latest)' "$tmp_file" \
            | cut -d ' ' -f 1 \
        )"
    fi
    koopa::rm "$tmp_file"
    [[ -n "$x" ]] || return 0
    koopa::print "$x"
    return 0
}

koopa::macos_brew_cask_quarantine_fix() { # {{{1
    # """
    # Homebrew cask fix for macOS quarantine.
    # @note Updated 2021-09-23.
    # """
    koopa::assert_has_no_args "$#"
    koopa::assert_is_macos
    koopa::assert_is_admin
    sudo xattr -r -d 'com.apple.quarantine' '/Applications/'*'.app'
    return 0
}

koopa::macos_brew_upgrade_casks() { # {{{1
    # """
    # Upgrade Homebrew casks.
    # @note Updated 2021-09-22.
    #
    # Note that additional cask flags are set globally using the
    # 'HOMEBREW_CASK_OPTS' global, declared in our main Homebrew activation
    # function.
    # """
    local cask casks str
    koopa::assert_has_no_args "$#"
    koopa::assert_is_macos
    koopa::assert_is_installed 'brew'
    readarray -t casks <<< "$(koopa::macos_brew_cask_outdated)"
    koopa::is_array_non_empty "${casks[@]:-}" || return 0
    str="$(koopa::ngettext "${#casks[@]}" 'cask' 'casks')"
    koopa::dl \
        "${#casks[@]} outdated ${str}" \
        "$(koopa::to_string "${casks[@]}")"
    for cask in "${casks[@]}"
    do
        case "$cask" in
            'docker')
                cask='homebrew/cask/docker'
                ;;
            'macvim')
                cask='homebrew/cask/macvim'
                ;;
        esac
        brew reinstall --cask --force "$cask" || true
        case "$cask" in
            'adoptopenjdk' | \
            'openjdk' | \
            'r' | \
            'temurin')
                koopa::configure_r
                ;;
            'microsoft-teams')
                koopa::macos_disable_microsoft_teams_updater
                ;;
        esac
    done
    return 0
}

