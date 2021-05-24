#!/bin/sh

_koopa_cd() { # {{{1
    # """
    # Change directory quietly.
    # @note Updated 2021-05-06.
    # """
    local cd
    [ "$#" -eq 1 ] || return 1
    cd='cd'
    _koopa_is_alias "$cd" && unalias "$cd"
    "$cd" "${1:?}" >/dev/null 2>&1 || return 1
    return 0
}

_koopa_parent_dir() { # {{{1
    # """
    # Get the parent directory path.
    # @note Updated 2021-05-24.
    #
    # This requires file to exist and resolves symlinks.
    # """
    local OPTIND cd_tail dirname file n parent sed 
    dirname="$(_koopa_locate_dirname)"
    cd_tail=''
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
        sed="$(_koopa_locate_sed)"
        cd_tail="$(printf "%${n}s" | "$sed" 's| |/..|g')"
    fi
    for file in "$@"
    do
        [ -e "$file" ] || return 1
        parent="$("$dirname" "$file")"
        parent="${parent}${cd_tail}"
        parent="$(_koopa_cd "$parent" && pwd -P)"
        _koopa_print "$parent"
    done
    return 0
}

# FIXME Attempting to use '_koopa_locate_readlink' is causing the shell to go into a loop.
# Where else is this being called?
_koopa_realpath() { # {{{1
    # """
    # Real path to file/directory on disk.
    # @note Updated 2021-05-24.
    #
    # Note that 'readlink -f' only works with GNU coreutils but not BSD
    # (i.e. macOS) variant.
    #
    # Python option:
    # > x="(python -c "import os; print(os.path.realpath('$1'))")"
    #
    # Perl option:
    # > x="$(perl -MCwd -e 'print Cwd::abs_path shift' "$1")"
    #
    # @seealso
    # - https://stackoverflow.com/questions/3572030/
    # - https://github.com/bcbio/bcbio-nextgen/blob/master/tests/run_tests.sh
    # """
    local readlink x
    # > readlink="$(_koopa_locate_readlink)"  # FIXME
    readlink='/usr/local/bin/greadlink'  # FIXME
    x="$("$readlink" -f "$@")"
    [ -n "$x" ] || return 1
    _koopa_print "$x"
    return 0
}

_koopa_which() { # {{{1
    # """
    # Locate which program.
    # @note Updated 2021-04-22.
    #
    # Example:
    # koopa::which bash
    # """
    local cmd
    for cmd in "$@"
    do
        _koopa_is_alias "$cmd" && unalias "$cmd"
        cmd="$(command -v "$cmd")"
        _koopa_print "$cmd"
    done
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
