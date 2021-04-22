#!/usr/bin/env bash

koopa::brew_brewfile() { # {{{1
    # """
    # Homebrew Bundle Brewfile path.
    # @note Updated 2020-11-20.
    # """
    local file subdir
    if koopa::is_macos
    then
        subdir='macos'
    else
        subdir='linux/common'
    fi
    file="$(koopa::prefix)/os/${subdir}/etc/homebrew/brewfile"
    [[ -f "$file" ]] || return 0
    koopa::print "$file"
    return 0
}

koopa::brew_cleanup() { # {{{1
    # """
    # Clean up Homebrew.
    # @note Updated 2021-04-22.
    # """
    koopa::assert_is_installed brew
    koopa::alert 'Cleaning up Homebrew install.'
    brew cleanup -s || true
    koopa::rm "$(brew --cache)"
    return 0
}

koopa::brew_dump_brewfile() { # {{{1
    # """
    # Dump a Homebrew Bundle Brewfile.
    # @note Updated 2020-11-20.
    # """
    local today
    today="$(koopa::today)"
    brew bundle dump \
        --file="brewfile-${today}" \
        --force
    return 0
}

koopa::brew_outdated() { # {{{1
    # """
    # Listed outdated Homebrew brews and casks, in a single call.
    # @note Updated 2021-04-22.
    # """
    local x
    koopa::assert_has_no_args "$#"
    x="$(brew outdated --quiet)"
    koopa::print "$x"
    return 0
}

koopa::brew_reset_core_repo() { # {{{1
    # """
    # Ensure internal 'homebrew-core' repo is clean.
    # @note Updated 2021-04-22.
    # """
    local branch origin
    koopa::assert_is_installed brew
    (
        koopa::cd "$(brew --repo 'homebrew/core')"
        origin='origin'
        branch="$(koopa::git_default_branch)"
        git checkout -q "$branch"
        git branch -q "$branch" -u "${origin}/${branch}"
        git reset -q --hard "${origin}/${branch}"
        # > git branch -vv
    )
    return 0
}

koopa::brew_reset_permissions() { # {{{1
    # """
    # Reset permissions on Homebrew installation.
    # @note Updated 2021-04-22.
    # """
    local group prefix user
    koopa::assert_is_installed brew
    koopa::assert_has_sudo
    user="$(koopa::user)"
    group="$(koopa::admin_group)"
    prefix="$(koopa::homebrew_prefix)"
    koopa::alert "Resetting '${prefix}' to '${user}:${group}'."
    sudo chown -Rh "${user}:${group}" "${prefix}/"*
    return 0
}

# FIXME HOW TO GET OUTDATED FORMULA SPECIFICALLY??
# FIXME DONT RUN THIS...CANT CUSTOMIZE...
# FIXME ONLY RETURN BREWS HERE, NOT CASKS!!!

koopa::brew_upgrade_brews() { # {{{1
    # """
    # Upgrade outdated Homebrew brews.
    # @note Updated 2021-04-22.
    # """
    readarray -t brews <<< "$(koopa::brew_outdated)"
    for brew in "${brews[@]}"
    do
        echo "$brew"  # FIXME
    done
    return 0
}
