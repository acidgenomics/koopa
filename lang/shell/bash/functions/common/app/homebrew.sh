#!/usr/bin/env bash

koopa::brew_cleanup() { # {{{1
    # """
    # Clean up Homebrew.
    # @note Updated 2021-11-22.
    # """
    local app
    koopa::assert_has_no_args "$#"
    declare -A app=(
        [brew]="$(koopa::locate_brew)"
    )
    koopa::alert 'Cleaning up Homebrew install.'
    "${app[brew]}" cleanup -s || true
    koopa::rm "$("${app[brew]}" --cache)"
    return 0
}

koopa::brew_dump_brewfile() { # {{{1
    # """
    # Dump a Homebrew Bundle Brewfile.
    # @note Updated 2021-10-27.
    # """
    local app today
    koopa::assert_has_no_args "$#"
    declare -A app=(
        [brew]="$(koopa::locate_brew)"
    )
    today="$(koopa::today)"
    "${app[brew]}" bundle dump \
        --file="brewfile-${today}" \
        --force
    return 0
}

koopa::brew_outdated() { # {{{1
    # """
    # Listed outdated Homebrew brews and casks, in a single call.
    # @note Updated 2021-10-27.
    # """
    local app x
    koopa::assert_has_no_args "$#"
    declare -A app=(
        [brew]="$(koopa::locate_brew)"
    )
    x="$("${app[brew]}" outdated --quiet)"
    koopa::print "$x"
    return 0
}

koopa::brew_reset_core_repo() { # {{{1
    # """
    # Ensure internal 'homebrew-core' repo is clean.
    # @note Updated 2021-10-27.
    # """
    local app branch origin prefix repo
    koopa::assert_has_no_args "$#"
    declare -A app=(
        [brew]="$(koopa::locate_brew)"
        [git]="$(koopa::locate_git)"
    )
    repo='homebrew/core'
    origin='origin'
    (
        prefix="$("${app[brew]}" --repo "$repo")"
        koopa::assert_is_dir "$prefix"
        koopa::cd "$prefix"
        branch="$(koopa::git_default_branch)"
        "${app[git]}" checkout -q "$branch"
        "${app[git]}" branch -q "$branch" -u "${origin}/${branch}"
        "${app[git]}" reset -q --hard "${origin}/${branch}"
        "${app[git]}" branch -vv
    )
    return 0
}

koopa::brew_reset_permissions() { # {{{1
    # """
    # Reset permissions on Homebrew installation.
    # @note Updated 2021-10-27.
    # """
    local group prefix user
    koopa::assert_has_no_args "$#"
    user="$(koopa::user)"
    group="$(koopa::admin_group)"
    prefix="$(koopa::homebrew_prefix)"
    koopa::alert "Resetting ownership of files in \
'${prefix}' to '${user}:${group}'."
    koopa::chown \
        --no-dereference \
        --recursive \
        --sudo \
        "${user}:${group}" \
        "${prefix}/"*
    return 0
}

koopa::brew_upgrade_brews() { # {{{1
    # """
    # Upgrade outdated Homebrew brews.
    # @note Updated 2021-10-27.
    # """
    local app brew brews str
    koopa::assert_has_no_args "$#"
    declare -A app=(
        [brew]="$(koopa::locate_brew)"
    )
    readarray -t brews <<< "$(koopa::brew_outdated)"
    koopa::is_array_non_empty "${brews[@]:-}" || return 0
    str="$(koopa::ngettext "${#brews[@]}" 'brew' 'brews')"
    koopa::dl \
        "${#brews[@]} outdated ${str}" \
        "$(koopa::to_string "${brews[@]}")"
    for brew in "${brews[@]}"
    do
        "${app[brew]}" reinstall --force "$brew" || true
        # Ensure specific brews are properly linked on macOS.
        if koopa::is_macos
        then
            case "$brew" in
                'gcc' | \
                'gpg' | \
                'ilmbase' | \
                'python@3.9' | \
                'vim')
                    "${app[brew]}" link --overwrite "$brew" || true
                    ;;
            esac
        fi
    done
    return 0
}
