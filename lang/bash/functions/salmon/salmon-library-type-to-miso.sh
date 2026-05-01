#!/usr/bin/env bash

_koopa_salmon_library_type_to_miso() {
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
    # > _koopa_salmon_library_type_to_miso 'IU'
    # # fr-unstranded
    # > _koopa_salmon_library_type_to_miso 'MU'
    # # fr-unstranded
    # > _koopa_salmon_library_type_to_miso 'ISR'
    # # fr-firststrand
    # """
    local from to
    _koopa_assert_has_args_eq "$#" 1
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
            _koopa_stop "Invalid library type: '${1:?}'."
            ;;
    esac
    _koopa_print "$to"
    return 0
}
