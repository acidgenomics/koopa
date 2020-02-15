#!/bin/sh
# shellcheck disable=SC2039

if ! _koopa_is_installed realpath
then
    realpath() {  # {{{1
        # """
        # Real path to file/directory on disk.
        # @note Updated 2020-01-13.
        #
        # Note that 'readlink -f' doesn't work on macOS.
        #
        # See also:
        # - https://github.com/bcbio/bcbio-nextgen/blob/master/tests/
        #       run_tests.sh
        # """
        if _koopa_is_macos
        then
            perl -MCwd -e 'print Cwd::abs_path shift' "$1"
        else
            readlink -f "$@"
        fi
    }
fi
