#!/bin/sh

koopa::add_conda_env_to_path() { # {{{1
    # """
    # Add conda environment(s) to PATH.
    # @note Updated 2020-06-30.
    # """
    # shellcheck disable=SC2039
    local bin_dir name
    koopa::assert_has_args "$#"
    koopa::assert_is_installed conda
    [[ -z "${CONDA_PREFIX:-}" ]] || return 1
    for name in "$@"
    do
        bin_dir="${CONDA_PREFIX}/envs/${name}/bin"
        if [[ ! -d "$bin_dir" ]]
        then
            koopa::warning "Conda environment missing: '${bin_dir}'."
            return 1
        fi
        koopa::add_to_path_start "$bin_dir"
    done
    return 0
}

koopa::list_path_priority() { # {{{1
    # """
    # Split PATH string by ':' delim into lines.
    # @note Updated 2019-10-27.
    #
    # Note that we're using awk approach here because it is shell agnostic.
    #
    # Bash here string parsing approach (non-POSIX):
    # Refer to heredoc format in 'man bash' for details.
    # > tr ':' '\n' <<< "$str"
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
    koopa::assert_has_args_le "$#" 1
    koopa::assert_is_installed awk
    local str
    str="${1:-$PATH}"
    x="$( \
        koopa::print "$str" \
        | awk '{split($0,array,":")} END { for (i in array) print array[i] }' \
    )"
    [ -n "$x" ] || return 1
    koopa::print "$x"
    return 0
}

koopa::list_path_priority_unique() { # {{{1
    # """
    # Split PATH string by ':' delim into lines but only return uniques.
    # @note Updated 2020-07-03.
    # """
    koopa::assert_is_installed awk tac
    local x
    x="$( \
        koopa::list_path_priority "$@" \
            | tac \
            | awk '!a[$0]++' \
            | tac \
    )"
    [ -n "$x" ] || return 1
    koopa::print "$x"
    return 0
}

koopa::which() { # {{{1
    # """
    # Locate which program.
    # @note Updated 2020-06-30.
    #
    # Note that this intentionally doesn't resolve symlinks.
    # Use 'koopa_realpath' for that output instead.
    #
    # Example:
    # koopa::which bash
    # ## /usr/local/bin/bash
    # """
    koopa::assert_has_args "$#"
    koopa::assert_is_installed "$@"
    local cmd
    for cmd in "$@"
    do
        koopa::is_alias "$cmd" && cmd="$(unalias "$cmd")"
        cmd="$(command -v "$cmd")"
        koopa::print "$cmd"
    done
    return 0
}

koopa::which_realpath() { # {{{1
    # """
    # Locate the realpath of a program.
    # @note Updated 2020-06-30.
    #
    # This resolves symlinks automatically.
    # For 'which' style return, use 'koopa::which' instead.
    #
    # @seealso
    # - https://stackoverflow.com/questions/7665
    # - https://unix.stackexchange.com/questions/85249
    # - https://stackoverflow.com/questions/7522712
    # - https://thoughtbot.com/blog/input-output-redirection-in-the-shell
    #
    # @examples
    # koopa::which_realpath bash vim
    # ## /usr/local/Cellar/bash/5.0.17/bin/bash
    # ## /usr/local/Cellar/vim/8.2.1050/bin/vim
    # """
    koopa::assert_has_args "$#"
    local cmd
    for cmd in "$@"
    do
        cmd="$(koopa::which "$cmd")"
        cmd="$(koopa::realpath "$cmd")"
        koopa::print "$cmd"
    done
    return 0
}
