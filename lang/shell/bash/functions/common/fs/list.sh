#!/usr/bin/env bash

koopa:::list_path_priority() { # {{{1
    # """
    # Split PATH string by ':' delim into lines.
    # @note Updated 2021-01-20.
    #
    # Alternate approach using tr:
    # > tr="$(koopa::locate_tr)"
    # > x="$("$tr" ':' '\n' <<< "$str")"
    #
    # Bash parameter expansion approach:
    # > koopa::print "${PATH//:/$'\n'}"
    #
    # see also:
    # - https://askubuntu.com/questions/600018
    # - https://stackoverflow.com/questions/26849247
    # - https://www.gnu.org/software/gawk/manual/html_node/String-Functions.html
    # - https://www.unix.com/shell-programming-and-scripting/
    #       77199-splitting-string-awk.html
    # """
    local str
    koopa::assert_has_args_le "$#" 1
    str="${1:-$PATH}"
    str="$(koopa::print "${str//:/$'\n'}")"
    [[ -n "$str" ]] || return 1
    koopa::print "$str"
    return 0
}

koopa:::list_path_priority_unique() { # {{{1
    # """
    # Split PATH string by ':' delim into lines but only return uniques.
    # @note Updated 2022-02-11.
    # """
    local app str
    declare -A app=(
        [awk]="$(koopa::locate_awk)"
        [tac]="$(koopa::locate_tac)"
    )
    # shellcheck disable=SC2016
    str="$( \
        koopa:::list_path_priority "$@" \
            | "${app[tac]}" \
            | "${app[awk]}" '!a[$0]++' \
            | "${app[tac]}" \
    )"
    [[ -n "$str" ]] || return 1
    koopa::print "$str"
    return 0
}

koopa::list_app_versions() { # {{{1
    # """
    # List installed application versions.
    # @note Updated 2022-02-11.
    # """
    local dict
    koopa::assert_has_no_args "$#"
    declare -A dict=(
        [prefix]="$(koopa::app_prefix)"
    )
    if [[ ! -d "${dict[prefix]}" ]]
    then
        koopa::alert_note "No apps are installed in '${dict[prefix]}'."
        return 0
    fi
    dict[str]="$( \
        koopa::find \
            --max-depth=2 \
            --min-depth=2 \
            --prefix="${dict[prefix]}" \
            --sort \
            --type='d' \
    )"
    [[ -n "${dict[str]}" ]] || return 1
    koopa::print "${dict[str]}"
    return 0
}

koopa::list_dotfiles() { # {{{1
    # """
    # List dotfiles.
    # @note Updated 2022-02-17.
    # """
    koopa::assert_has_no_args "$#"
    koopa::h1 "Listing dotfiles in '${HOME:?}'."
    koopa::find_dotfiles 'd' 'Directories'
    koopa::find_dotfiles 'f' 'Files'
    koopa::find_dotfiles 'l' 'Symlinks'
}

koopa::list_path_priority() { # {{{1
    # """
    # List path priority.
    # @note Updated 2022-02-11.
    # """
    local all_arr app dict unique_arr
    declare -A app=(
        [awk]="$(koopa::locate_awk)"
    )
    declare -A dict
    readarray -t all_arr <<< "$( \
        koopa:::list_path_priority "$@" \
    )"
    koopa::is_array_non_empty "${all_arr[@]:-}" || return 1
    # shellcheck disable=SC2016
    readarray -t unique_arr <<< "$( \
        koopa::print "${all_arr[@]}" \
            | "${app[awk]}" '!a[$0]++' \
    )"
    koopa::is_array_non_empty "${unique_arr[@]:-}" || return 1
    dict[n_all]="${#all_arr[@]}"
    dict[n_unique]="${#unique_arr[@]}"
    dict[n_dupes]="$((dict[n_all] - dict[n_unique]))"
    if [[ "${dict[n_dupes]}" -gt 0 ]]
    then
        koopa::alert_note "$(koopa::ngettext \
            --num="${dict[n_dupes]}" \
            --msg1='duplicate' \
            --msg2='duplicates' \
            --suffix=' detected.' \
        )"
    fi
    koopa::print "${all_arr[@]}"
    return 0
}
