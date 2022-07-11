#!/usr/bin/env bash

# FIXME Only set FC and FLIBS for R CRAN framework on macOS.
# FIXME Rework our GCC configuration approach.
# FIXME Need to update the Makevars only for R CRAN binary.

koopa_r_makevars() {
    # """
    # Generate 'Makevars.site' file with compiler settings.
    # @note Updated 2022-07-11.
    # """
    local app dict
    koopa_assert_has_args_le "$#" 1
    declare -A app=(
        [r]="${1:-}"
    )
    [[ -z "${app[r]}" ]] && app[r]="$(koopa_locate_r)"
    app[r]="$(koopa_which_realpath "${app[r]}")"
    declare -A dict=(
        [arch]="$(koopa_arch)" # e.g. 'x86_64'.
        [opt_prefix]="$(koopa_opt_prefix)"
    )
    dict[gcc_prefix]="$(koopa_realpath "${dict[opt_prefix]}/gcc")"
    dict[cc]="${dict[gcc_prefix]}/bin/gcc"
    dict[cxx]="${dict[gcc_prefix]}/bin/g++"
    dict[fc]="${dict[gcc_prefix]}/bin/gfortran"

    # FIXME Need to handle GCC string here...look up libs manually instead.

    dict[flibs]="-L${dict[gcc_prefix]}/lib/gcc/${dict[arch]}-apple-darwin21/12.1.0 -L${dict[gcc_prefix]}/lib -lgfortran -lquadmath -lm"

    # FIXME Need to handle macOS approach.
    if koopa_is_koopa_app "${app[r]}"
    then
        # FIXME Write CC and CXX here in addition to FC and FLIBS.
    else
        # R CRAN binary.
        # FIXME Only write FC and FLIBS here.
    fi

    # FIXME Return the lines during debugging.
    # FIXME Need to write this file in final version.

    return 0
}
