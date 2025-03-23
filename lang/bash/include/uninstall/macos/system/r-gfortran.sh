#!/usr/bin/env bash

main() {
    # """
    # Uninstall GNU Fortran (for R).
    # @note Updated 2023-10-09.
    #
    # @seealso
    # - https://mac.r-project.org/tools/
    # """
    local -A dict
    dict['prefix']='/opt/gfortran'
    koopa_assert_is_dir "${dict['prefix']}"
    koopa_rm --sudo "${dict['prefix']}"
    return 0
}
