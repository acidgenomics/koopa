#!/usr/bin/env bash

_koopa_salmon_library_type_to_kallisto() {
    # """
    # Convert salmon library type to kallisto conventions.
    # @note Updated 2023-11-16.
    #
    # @seealso
    # - https://salmon.readthedocs.io/en/latest/library_type.html
    # - https://littlebitofdata.com/en/2017/08/strandness_in_rnaseq/
    # - https://github.com/bcbio/bcbio-nextgen/blob/master/bcbio/rnaseq/
    #     kallisto.py
    #
    # @examples
    # > _koopa_salmon_library_type_to_kallisto 'ISF'
    # # --fr-stranded
    # > _koopa_salmon_library_type_to_kallisto 'ISR'
    # # --rf-stranded
    # """
    local from to
    _koopa_assert_has_args_eq "$#" 1
    from="${1:?}"
    case "$from" in
        'IU' | 'MU' | 'OU' | 'U')
            # fr-unstranded.
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
            _koopa_stop "Invalid library type: '${1:?}'."
            ;;
    esac
    _koopa_print "$to"
    return 0
}
