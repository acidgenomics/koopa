#!/usr/bin/env bash

koopa_rmats_library_type() {
    # """
    # Convert salmon library type to rMATS conventions.
    # @note Updated 2023-11-16.
    #
    # @seealso
    # - https://salmon.readthedocs.io/en/latest/library_type.html
    # - https://littlebitofdata.com/en/2017/08/strandness_in_rnaseq/
    #
    # @examples
    # > koopa_rmats_library_type 'IU'
    # # --fr-unstranded
    # > koopa_rmats_library_type 'MU'
    # # --fr-unstranded
    # """
    local from to
    koopa_assert_has_args_eq "$#" 1
    from="${1:?}"
    case "$from" in
        'IU' | 'MU' | 'OU' | 'U')
            to='--fr-unstranded'
            return 0
            ;;
        'ISF')
            # fr-secondstrand (ligation).
            to='--fr-stranded'
            ;;
        'ISR')
            # fr-firststrand (dUTP).
            to='--rf-stranded'
            ;;
        *)
            koopa_stop "Invalid library type: '${1:?}'."
            ;;
    esac
    koopa_print "$to"
    return 0
}
