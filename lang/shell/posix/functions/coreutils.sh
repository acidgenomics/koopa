#!/bin/sh

_koopa_realpath() { # {{{1
    # """
    # Real path to file/directory on disk.
    # @note Updated 2021-05-26.
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
    local brew_prefix readlink x
    readlink='readlink'
    if _koopa_is_macos
    then
        brew_prefix="$(_koopa_homebrew_prefix)"
        readlink="${brew_prefix}/opt/coreutils/bin/greadlink"
    fi
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
