#!/usr/bin/env bash

koopa::_list_path_priority() { # {{{1
    # """
    # Split PATH string by ':' delim into lines.
    # @note Updated 2020-11-10.
    #
    # Alternate approach using tr:
    # > x="$(tr ':' '\n' <<< "$str")"
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
    x="$(koopa::print "${str//:/$'\n'}")"
    [[ -n "$x" ]] || return 1
    koopa::print "$x"
    return 0
}

koopa::_list_path_priority_unique() { # {{{1
    # """
    # Split PATH string by ':' delim into lines but only return uniques.
    # @note Updated 2020-07-03.
    # """
    local x
    koopa::assert_is_installed awk tac
    x="$( \
        koopa::_list_path_priority "$@" \
            | tac \
            | awk '!a[$0]++' \
            | tac \
    )"
    [[ -n "$x" ]] || return 1
    koopa::print "$x"
    return 0
}

koopa::list() { # {{{1
    # """
    # List koopa programs available in PATH.
    # @note Updated 2021-01-04.
    # """
    koopa::rscript_vanilla 'listPrograms'
    return 0
}

koopa::list_app_versions() { # {{{1
    # """
    # List installed application versions.
    # @note Updated 2020-11-23.
    # """
    local prefix
    koopa::assert_has_no_args "$#"
    prefix="$(koopa::app_prefix)"
    if [[ ! -d "$prefix" ]]
    then
        koopa::note "No applications are installed in '${prefix}'."
        return 0
    fi
    # This approach doesn't work well when only a single program is installed.
    # > ls -1 -- "${prefix}/"*
    find "$prefix" -mindepth 2 -maxdepth 2 -type d | sort
    return 0
}

koopa::list_dotfiles() { # {{{1
    # """
    # List dotfiles.
    # @note Updated 2020-11-25.
    # """
    koopa::assert_has_no_args "$#"
    koopa::h1 'Listing dotfiles.'
    koopa::find_dotfiles d 'Directories'
    koopa::find_dotfiles f 'Files'
    koopa::find_dotfiles l 'Symlinks'
}

koopa::list_path_priority() { # {{{1
    # """
    # List path priority.
    # @note Updated 2020-07-10.
    # """
    local all all_arr n_all n_dupes n_unique unique
    koopa::assert_is_installed awk
    all="$(koopa::_list_path_priority "$@")"
    readarray -t all_arr <<< "$(koopa::print "$all")"
    unique="$(koopa::print "$all" | awk '!a[$0]++')"
    readarray -t unique_arr <<< "$(koopa::print "$unique")"
    n_all="${#all_arr[@]}"
    n_unique="${#unique_arr[@]}"
    n_dupes="$((n_all-n_unique))"
    if [[ "$n_dupes" -gt 0 ]]
    then
        koopa::note "${n_dupes} duplicate(s) detected."
    fi
    koopa::print "$all"
    return 0
}
