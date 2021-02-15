#!/bin/sh

_koopa_cd() { # {{{1
    # """
    # Change directory quietly.
    # @note Updated 2020-07-20.
    # """
    # shellcheck disable=SC2039
    local cd
    unalias -a
    [ "$#" -eq 1 ] || return 1
    cd='cd'
    "$cd" "${1:?}" >/dev/null 2>&1 || return 1
    return 0
}

_koopa_parent_dir() { # {{{1
    # """
    # Get the parent directory path.
    # @note Updated 2020-07-20.
    #
    # This requires file to exist and resolves symlinks.
    # """
    # shellcheck disable=SC2039
    local OPTIND cd_tail file n parent
    _koopa_is_installed dirname printf pwd sed || return 1
    cd_tail=
    n=1
    OPTIND=1
    while getopts 'n:' opt
    do
        case "$opt" in
            n)
                n="${OPTARG}"
                ;;
            \?)
                koopa::invalid_arg
                ;;
        esac
    done
    shift "$((OPTIND-1))"
    [ "$n" -ge 1 ] || n=1
    if [ "$n" -ge 2 ]
    then
        n="$((n-1))"
        cd_tail="$(printf "%${n}s" | sed 's| |/..|g')"
    fi
    for file in "$@"
    do
        [ -e "$file" ] || return 1
        parent="$(dirname "$file")"
        parent="${parent}${cd_tail}"
        parent="$(_koopa_cd "$parent" && pwd -P)"
        _koopa_print "$parent"
    done
    return 0
}

_koopa_realpath() { # {{{1
    # """
    # Real path to file/directory on disk.
    # @note Updated 2020-07-20.
    #
    # Note that 'readlink -f' doesn't work on macOS.
    #
    # @seealso
    # - https://github.com/bcbio/bcbio-nextgen/blob/master/tests/run_tests.sh
    # """
    # shellcheck disable=SC2039
    local arg x
    [ "$#" -gt 0 ] || return 1
    if _koopa_is_installed realpath
    then
        x="$(realpath "$@")"
        _koopa_print "$x"
    elif _koopa_has_gnu readlink
    then
        x="$(readlink -f "$@")"
        _koopa_print "$x"
    elif _koopa_is_installed perl
    then
        for arg in "$@"
        do
            x="$(perl -MCwd -e 'print Cwd::abs_path shift' "$arg")"
            _koopa_print "$x"
        done
    else
        return 1
    fi
    return 0
}

_koopa_which_realpath() { # {{{1
    # """
    # Locate the realpath of a program.
    # @note Updated 2020-07-20.
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
    # """
    # shellcheck disable=SC2039
    local cmd
    [ "$#" -gt 0 ] || return 1
    for cmd in "$@"
    do
        cmd="$(_koopa_which "$cmd")"
        cmd="$(_koopa_realpath "$cmd")"
        _koopa_print "$cmd"
    done
    return 0
}
