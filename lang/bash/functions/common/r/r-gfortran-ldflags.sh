#!/usr/bin/env bash

koopa_r_gfortran_ldflags() {
    # """
    # LDFLAGS for R Fortran configuration.
    # @note Updated 2023-10-10.
    # """
    local -a flibs ldflags
    local flib rpath
    koopa_assert_has_no_args "$#"
    readarray -d ' ' -t flibs <<< "$(koopa_r_gfortran_libs)"
    for flib in "${flibs[@]}"
    do
        case "$flib" in
            '-L'*)
                ldflags+=("$flib")
                rpath="$( \
                    koopa_sub \
                        --pattern='-L' \
                        --replacement='' \
                        "$flib" \
                )"
                rpath="-Wl,-rpath,${rpath}"
                ldflags+=("$rpath")
                ;;
        esac
    done
    koopa_print "${ldflags[*]}"
    return 0
}
