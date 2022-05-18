#!/usr/bin/env bash

koopa_macos_brew_cask_outdated() {
    # """
    # List outdated Homebrew casks.
    # @note Updated 2021-10-27.
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
    local app keep_latest tmp_file x
    koopa_assert_has_no_args "$#"
    declare -A app=(
        [brew]="$(koopa_locate_brew)"
        [cut]="$(koopa_locate_cut)"
    )
    # Whether we want to keep unversioned 'latest' casks returned with
    # '--greedy'. This tends to include font casks and the Google Cloud SDK,
    # which are annoying to have reinstall with each update, so disabling
    # here by default.
    keep_latest=0
    # This approach keeps the version information, which we can parse.
    tmp_file="$(koopa_tmp_file)"
    script -q "$tmp_file" \
        "${app[brew]}" outdated --cask --greedy >/dev/null
    if [[ "$keep_latest" -eq 1 ]]
    then
        x="$("${app[cut]}" -d ' ' -f '1' < "$tmp_file")"
    else
        x="$( \
            koopa_grep \
                --file="$tmp_file" \
                --invert-match \
                --pattern='(latest)' \
            | "${app[cut]}" -d ' ' -f '1' \
        )"
    fi
    koopa_rm "$tmp_file"
    [[ -n "$x" ]] || return 0
    koopa_print "$x"
    return 0
}
