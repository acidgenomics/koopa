#!/bin/sh

_koopa_realpath() {
    # """
    # Real path to file/directory on disk.
    # @note Updated 2023-03-23.
    #
    # @seealso
    # - https://stackoverflow.com/questions/3572030/
    # - https://github.com/bcbio/bcbio-nextgen/blob/master/tests/run_tests.sh
    # """
    for __kvar_arg in "$@"
    do
        __kvar_string="$(readlink -f "$__kvar_arg" 2>/dev/null)"
        if [ -z "$__kvar_string" ]
        then
            __kvar_string="$( \
                perl -MCwd -le \
                    'print Cwd::abs_path shift' \
                    "$__kvar_arg" \
                2>/dev/null \
            )"
        fi
        if [ -z "$__kvar_string" ]
        then
            __kvar_string="$( \
                python3 -c \
                    "import os; print(os.path.realpath('${__kvar_arg}'))" \
                2>/dev/null \
            )"
        fi
        if [ -z "$__kvar_string" ]
        then
            unset -v __kvar_arg _kvar_string
            return 1
        fi
        __koopa_print "$__kvar_string"
    done
    unset -v __kvar_arg __kvar_string
    return 0
}
