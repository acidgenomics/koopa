#!/usr/bin/env bash

koopa_salmon_library_type_to_rsem() {
    # """
    # Convert salmon library type to RSEM conventions.
    # @note Updated 2023-11-16.
    #
    # Recommended approach:
    # --strandedness <none|forward|reverse>
    #     This option defines the strandedness of the RNA-Seq reads. It
    #     recognizes three values: 'none', 'forward', and 'reverse'. 'none'
    #     refers to non-strand-specific protocols. 'forward' means all
    #     (upstream) reads are derived from the forward strand. 'reverse' means
    #     all (upstream) reads are derived from the reverse strand. If
    #     'forward'/'reverse' is set, the '--norc'/'--nofw' Bowtie/Bowtie 2
    #     option will also be enabled to avoid aligning reads to the opposite
    #     strand. For Illumina TruSeq Stranded protocols, please use 'reverse'.
    #
    # Deprecated approach:
    # --forward-prob <double>
    #     Probability of generating a read from the forward strand of a
    #     transcript. Set to 1 for a strand-specific protocol where all
    #     (upstream) reads are derived from the forward strand, 0 for a
    #     strand-specific protocol where all (upstream) read are derived from
    #     the reverse strand, or 0.5 for a non-strand-specific protocol.
    #
    # For Illumina TruSeq Stranded protocols, use '--strandedness reverse'.
    #
    # @seealso
    # - https://salmon.readthedocs.io/en/latest/library_type.html
    # - https://littlebitofdata.com/en/2017/08/strandness_in_rnaseq/
    # - https://deweylab.github.io/RSEM/rsem-calculate-expression.html
    #
    # @examples
    # > koopa_salmon_library_type_to_rsem 'ISF'
    # # forward
    # > koopa_salmon_library_type_to_rsem 'ISR'
    # # reverse
    # > koopa_salmon_library_type_to_rsem 'IU'
    # # none
    # """
    local from to
    koopa_assert_has_args_eq "$#" 1
    from="${1:?}"
    case "$from" in
        'IU' | 'U')
            # fr-unstranded.
            # Deprecated: '--forward-prob 0.5'.
            to='none'
            ;;
        'ISF')
            # fr-secondstrand (ligation).
            # Deprecated: '--forward-prob 1'.
            to='forward'
            ;;
        'ISR')
            # fr-firststrand (dUTP).
            # Deprecated: '--forward-prob 0'.
            to='reverse'
            ;;
        *)
            koopa_stop "Invalid library type: '${1:?}'."
            ;;
    esac
    koopa_print "$to"
    return 0
}
