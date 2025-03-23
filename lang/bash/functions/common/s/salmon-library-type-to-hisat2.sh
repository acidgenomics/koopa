#!/usr/bin/env bash

koopa_salmon_library_type_to_hisat2() {
    # """
    # Convert salmon library type to HISAT2 strandedness.
    # @note Updated 2023-11-16.
    #
    # @seealso
    # - https://salmon.readthedocs.io/en/latest/library_type.html
    # - https://rnabio.org/module-09-appendix/0009/12/01/StrandSettings/
    # - https://github.com/bcbio/bcbio-nextgen/blob/master/bcbio/
    #     ngsalign/hisat2.py
    #
    # @examples
    # > koopa_salmon_library_type_to_hisat2 'ISF'
    # # FR
    # > koopa_salmon_library_type_to_hisat2 'ISR'
    # # RF
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
            to='FR'
            ;;
        'ISR')
            # fr-firststrand (dUTP).
            to='RF'
            ;;
        'SF')
            # fr-secondstrand.
            to='F'
            ;;
        'SR')
            # fr-firststrand.
            to='R'
            ;;
        *)
            koopa_stop "Invalid library type: '${1:?}'."
            ;;
    esac
    koopa_print "$to"
    return 0
}
