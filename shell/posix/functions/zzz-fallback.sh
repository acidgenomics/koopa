#!/bin/sh
# shellcheck disable=SC2039

if ! _koopa_is_installed realpath
then
    realpath() {                                                          # {{{3
        # """
        # Real path to file/directory on disk.
        # Updated 2019-06-26.
        #
        # Note that 'readlink -f' doesn't work on macOS.
        #
        # See also:
        # - https://github.com/bcbio/bcbio-nextgen/blob/master/tests/
        #       run_tests.sh
        # """
        if [ "$(uname -s)" = "Darwin" ]
        then
            perl -MCwd -e 'print Cwd::abs_path shift' "$1"
        else
            readlink -f "$@"
        fi
    }
fi
