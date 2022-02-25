#!/usr/bin/env bash

koopa_brew_cleanup() { # {{{1
    # """
    # Clean up Homebrew.
    # @note Updated 2021-11-22.
    # """
    local app
    koopa_assert_has_no_args "$#"
    declare -A app=(
        [brew]="$(koopa_locate_brew)"
    )
    koopa_alert 'Cleaning up Homebrew install.'
    "${app[brew]}" cleanup -s || true
    koopa_rm "$("${app[brew]}" --cache)"
    return 0
}

koopa_brew_dump_brewfile() { # {{{1
    # """
    # Dump a Homebrew Bundle Brewfile.
    # @note Updated 2021-10-27.
    # """
    local app today
    koopa_assert_has_no_args "$#"
    declare -A app=(
        [brew]="$(koopa_locate_brew)"
    )
    today="$(koopa_today)"
    "${app[brew]}" bundle dump \
        --file="brewfile-${today}" \
        --force
    return 0
}

koopa_brew_outdated() { # {{{1
    # """
    # Listed outdated Homebrew brews and casks, in a single call.
    # @note Updated 2021-10-27.
    # """
    local app x
    koopa_assert_has_no_args "$#"
    declare -A app=(
        [brew]="$(koopa_locate_brew)"
    )
    x="$("${app[brew]}" outdated --quiet)"
    koopa_print "$x"
    return 0
}

koopa_brew_reset_core_repo() { # {{{1
    # """
    # Ensure internal 'homebrew-core' repo is clean.
    # @note Updated 2021-10-27.
    # """
    local app branch origin prefix repo
    koopa_assert_has_no_args "$#"
    declare -A app=(
        [brew]="$(koopa_locate_brew)"
        [git]="$(koopa_locate_git)"
    )
    repo='homebrew/core'
    origin='origin'
    (
        prefix="$("${app[brew]}" --repo "$repo")"
        koopa_assert_is_dir "$prefix"
        koopa_cd "$prefix"
        branch="$(koopa_git_default_branch)"
        "${app[git]}" checkout -q "$branch"
        "${app[git]}" branch -q "$branch" -u "${origin}/${branch}"
        "${app[git]}" reset -q --hard "${origin}/${branch}"
        "${app[git]}" branch -vv
    )
    return 0
}

koopa_brew_reset_permissions() { # {{{1
    # """
    # Reset permissions on Homebrew installation.
    # @note Updated 2021-10-27.
    # """
    local group prefix user
    koopa_assert_has_no_args "$#"
    user="$(koopa_user)"
    group="$(koopa_admin_group)"
    prefix="$(koopa_homebrew_prefix)"
    koopa_alert "Resetting ownership of files in \
'${prefix}' to '${user}:${group}'."
    koopa_chown \
        --no-dereference \
        --recursive \
        --sudo \
        "${user}:${group}" \
        "${prefix}/"*
    return 0
}

koopa_brew_upgrade_brews() { # {{{1
    # """
    # Upgrade outdated Homebrew brews.
    # @note Updated 2022-02-16.
    # """
    local app brew brews
    koopa_assert_has_no_args "$#"
    declare -A app=(
        [brew]="$(koopa_locate_brew)"
    )
    readarray -t brews <<< "$(koopa_brew_outdated)"
    koopa_is_array_non_empty "${brews[@]:-}" || return 0
    koopa_dl \
        "$(koopa_ngettext \
            --num="${#brews[@]}" \
            --middle=' outdated ' \
            --msg1='brew' \
            --msg2='brews' \
        )" \
        "$(koopa_to_string "${brews[@]}")"
    for brew in "${brews[@]}"
    do
        "${app[brew]}" reinstall --force "$brew" || true
        # Ensure specific brews are properly linked on macOS.
        if koopa_is_macos
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
