#!/bin/sh

_koopa_realpath() {
    # """
    # Real path to file/directory on disk.
    # @note Updated 2022-08-26.
    #
    # macOS/BSD readlink now supports '-f' flag.
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
    local x
    x="$(readlink -f "$@")"
    [ -n "$x" ] || return 1
    _koopa_print "$x"
    return 0
}
