#!/usr/bin/env bash

_koopa_check_exports() {
    # """
    # Check exported environment variables.
    # @note Updated 2020-07-05.
    #
    # Warn the user if they are setting unrecommended values.
    # """
    local -a vars
    _koopa_assert_has_no_args "$#"
    _koopa_is_rstudio && return 0
    vars=(
        'JAVA_HOME'
        'LD_LIBRARY_PATH'
        'PYTHONHOME'
        'R_HOME'
    )
    _koopa_warn_if_export "${vars[@]}"
    return 0
}
