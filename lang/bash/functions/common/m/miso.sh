#!/usr/bin/env bash

# NOTE Consider separating indexing and run steps.

# FIXME Detect single vs. paired reads.
# FIXME Detect the read length and set '--read-len' value.
# FIXME Check for corresponding BAM index file (.bam.bai).

# NOTE Consider setting this for STAR run, which is n-1:
# If reads were aligned to a set of splice junctions with an overhang constraint — i.e., a requirement that N or more bases from each side of the junction must be covered by the read — then this can be specified using the --overhang-len option:
# --overhang-len
# Length of overhang constraints imposed on junctions.

# FIXME Set paired end mode when relevant:
# --paired-end
#                       Run in paired-end mode. Takes mean and standard
#                       deviation of insert length distribution.
#
# The insert length distribution gives the range of sizes of fragments sequenced in the paired-end RNA-Seq run. This is used to assign reads to isoforms probabilistically. The insert length distribution can be computed by aligning read pairs to long, constitutive exons (like 3’ UTRs) and measuring the distance between the read mates. The mean and standard deviation of this distribution would then be given as arguments to --paired-end. For example, to run on a paired-end sample where the mean insert length is 250 and the standard deviation is 15, we would use: --paired-end 250 15 when calling miso (in addition to the --run option).
#
# The utilities in exon_utils and pe_utils can be used to first get a set of long constitituve exons to map read pairs to, and second compute the insert length distribution and its statistics.
#
# https://github.com/bcbio/bcbio-nextgen/pull/1214#issuecomment-191281690

koopa_miso() {
    # """
    # Run MISO splicing analysis.
    # @note Updated 2023-11-17.
    #
    # This expects a sorted, indexed BAM file as input.
    #
    # @seealso
    # - https://miso.readthedocs.io/en/fastmiso/
    # - http://hollywood.mit.edu/burgelab/miso/
    # - https://nf-co.re/rnasplice/
    # - https://github.com/nf-core/rnasplice/blob/master/modules/
    #     local/miso_run.nf
    # - https://github.com/nf-core/rnasplice/blob/master/modules/
    #     local/miso_index.nf
    # """
    local -A app dict
    local -a miso_args
    app['miso']="$(koopa_locate_miso)"
    koopa_assert_is_executable "${app[@]}"
    dict['bam_file']=''
    dict['read_length']=''
    # e.g. 'miso/star-gencode/treatment-vs-control'.
    dict['output_dir']=''
    # FIXME Set the log file.
    koopa_assert_is_set \
        '--bam-file' "${dict['bam_file']}" \
        '--output-dir' "${dict['output_dir']}"
    # MISO index steps:
    # index_gff --index $gff3 $index
    miso_args+=(
        '--output-dir' "${dict['output_dir']}"
        '--read-len' "${dict['read_length']}"
        '--run' "${dict['bam_file']}"
    )
    # FIXME Use tee here.
    "${app['miso']}" "${miso_args[@]}"
    # FIXME Output console to log file.
    #
    # nf-core uses:
    # miso --run ${miso_index} $bams --output-dir miso_data/${meta.id} --read-len $miso_read_len
    return 0
}
