#!/bin/sh

# NOTE Consider using GNU 'realpath' as top priority, if installed.

koopa_realpath() {
    # """
    # Real path to file/directory on disk.
    # @note Updated 2022-04-08.
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
    readlink='readlink'
    if ! koopa_is_installed "$readlink"
    then
        local brew_readlink koopa_readlink
        koopa_readlink="$(koopa_opt_prefix)/coreutils/bin/readlink"
        brew_readlink="$(koopa_homebrew_opt_prefix)/coreutils/libexec/\
gnubin/readlink"
        if [ -x "$koopa_readlink" ]
        then
            readlink="$koopa_readlink"
        elif [ -x "$brew_readlink" ]
        then
            readlink="$brew_readlink"
        else
            return 1
        fi
    fi
    x="$("$readlink" -f "$@")"
    [ -n "$x" ] || return 1
    koopa_print "$x"
    return 0
}
