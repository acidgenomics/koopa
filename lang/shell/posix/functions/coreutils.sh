#!/bin/sh

_koopa_realpath() { # {{{1
    # """
    # Real path to file/directory on disk.
    # @note Updated 2021-06-04.
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
    [ "$#" -gt 0 ] || return 1
    readlink='readlink'
    if _koopa_is_macos
    then
        brew_prefix="$(_koopa_homebrew_prefix)"
        readlink="${brew_prefix}/opt/coreutils/bin/greadlink"
    fi
    x="$("$readlink" -f "$@")"
    [ -e "$x" ] || return 1
    _koopa_print "$x"
    return 0
}
