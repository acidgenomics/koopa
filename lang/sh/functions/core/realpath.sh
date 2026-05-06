#!/bin/sh

_koopa_realpath() {
    # """
    # Real path to file/directory on disk.
    # @note Updated 2026-05-06.
    #
    # @seealso
    # - https://stackoverflow.com/questions/3572030/
    # - https://github.com/bcbio/bcbio-nextgen/blob/master/tests/run_tests.sh
    # """
    for _kvar_rp_arg in "$@"
    do
        _kvar_rp_string="$( \
            readlink -f "$_kvar_rp_arg" \
            2>/dev/null \
            || true \
        )"
        if [ -z "$_kvar_rp_string" ]
        then
            _kvar_rp_string="$( \
                perl -MCwd -le \
                    'print Cwd::abs_path shift' \
                    "$_kvar_rp_arg" \
                2>/dev/null \
                || true \
            )"
        fi
        if [ -z "$_kvar_rp_string" ]
        then
            _kvar_rp_string="$( \
                python3 -c \
                    "import os,sys; print(os.path.realpath(sys.argv[1]))" \
                    "$_kvar_rp_arg" \
                2>/dev/null \
                || true \
            )"
        fi
        if [ -z "$_kvar_rp_string" ]
        then
            unset -v _kvar_rp_arg _kvar_rp_string
            return 1
        fi
        __koopa_print "$_kvar_rp_string"
    done
    unset -v _kvar_rp_arg _kvar_rp_string
    return 0
}
