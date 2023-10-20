#!/usr/bin/env bash

koopa_kallisto_fastq_library_type() {
    # """
    # Convert salmon FASTQ library type to kallisto conventions.
    # @note Updated 2023-10-20.
    #
    # @seealso
    # - https://salmon.readthedocs.io/en/latest/library_type.html
    # - https://littlebitofdata.com/en/2017/08/strandness_in_rnaseq/
    # - https://github.com/bcbio/bcbio-nextgen/blob/master/bcbio/rnaseq/
    #     kallisto.py
    #
    # @examples
    # > koopa_kallisto_fastq_library_type 'ISF'
    # # --fr-stranded
    # > koopa_kallisto_fastq_library_type 'ISR'
    # # --rf-stranded
    # """
    local from to
    koopa_assert_has_args_eq "$#" 1
    from="${1:?}"
    case "$from" in
        'IU' | 'U')
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
            koopa_stop "Invalid library type: '${1:?}'."
            ;;
    esac
    koopa_print "$to"
    return 0
}
