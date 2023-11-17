#!/usr/bin/env bash

koopa_salmon_library_type_to_rmats() {
    # """
    # Convert salmon library type to MISO conventions.
    # @note Updated 2023-11-16.
    #
    # @seealso
    # - https://miso.readthedocs.io/en/fastmiso/
    # - https://salmon.readthedocs.io/en/latest/library_type.html
    # - https://littlebitofdata.com/en/2017/08/strandness_in_rnaseq/
    #
    # @examples
    # > koopa_salmon_library_type_to_miso 'IU'
    # # fr-unstranded
    # > koopa_salmon_library_type_to_miso 'MU'
    # # fr-unstranded
    # > koopa_salmon_library_type_to_miso 'ISR'
    # # fr-firststrand
    # """
    local from to
    koopa_assert_has_args_eq "$#" 1
    from="${1:?}"
    case "$from" in
        'IU' | 'MU' | 'OU' | 'U')
            to='fr-unstranded'
            ;;
        'ISF')
            to='fr-secondstrand'
            ;;
        'ISR')
            to='fr-firststrand'
            ;;
        *)
            koopa_stop "Invalid library type: '${1:?}'."
            ;;
    esac
    koopa_print "$to"
    return 0
}
