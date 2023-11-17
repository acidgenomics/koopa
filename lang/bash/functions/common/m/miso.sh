#!/usr/bin/env bash

# FIXME This needs to take multiple BAM files as input.
# FIXME Detect single vs. paired reads.
# FIXME Detect the read length and set '--read-len' value.
# FIXME Check for corresponding BAM index file (.bam.bai).

# NOTE Consider setting this for STAR run, which is n-1:
# If reads were aligned to a set of splice junctions with an overhang constraint — i.e., a requirement that N or more bases from each side of the junction must be covered by the read — then this can be specified using the --overhang-len option:
# --overhang-len
# Length of overhang constraints imposed on junctions.

# FIXME Set paired end mode when relevant:
#
# The utilities in exon_utils and pe_utils can be used to first get a set of long constitituve exons to map read pairs to, and second compute the insert length distribution and its statistics.
#
# https://github.com/bcbio/bcbio-nextgen/pull/1214#issuecomment-191281690
#
# insert length is 250 and the standard deviation is 15
#
#   --settings-filename=SETTINGS_FILENAME
#                        Filename specifying MISO settings.#

koopa_miso() {
    # """
    # Run MISO splicing event analysis.
    # @note Updated 2023-11-17.
    #
    # This expects a sorted, indexed BAM file as input.
    #
    # @section Configuring MISO:
    #
    # The default configuration file for MISO is available in
    # 'settings/miso_settings.txt'.
    #
    # How to set strandedness:
    # [data]
    # strand = fr-unstranded
    #
    # The [data] section contains parameters related to the way reads should be
    # handled. These are:
    # - filter_results: Specifies whether or not events should be filtered for
    #   coverage (True or False).
    # - min_event_reads: What the minimum number of reads that a region must
    #   have for it to be quantitated. The minimum number of reads is computed
    #   over the longest genomic region of the gene or alternatively spliced
    #   event.
    # - strand (optional): What the strand convention of the input BAM files is.
    #   Can be set to either fr-unstranded, fr-firststrand, or fr-secondstrand.
    #   Set to fr-unstranded by default. See Note on strand-specificity in
    #   RNA-Seq libraries for an explanation of these strand conventions.
    #
    # May need to set MISO configuration regarding strandedness:
    # - https://mailman.mit.edu/pipermail/miso-users/
    #     Week-of-Mon-20130805/000257.html
    #
    # @section Paired-end analysis:
    #
    # https://miso.readthedocs.io/en/fastmiso/#using-paired-end-reads
    #
    # --paired-end: Run in paired-end mode. Takes mean and standard deviation of
    # insert length distribution.
    #
    # The insert length distribution gives the range of sizes of fragments
    # sequenced in the paired-end RNA-Seq run. This is used to assign reads to
    # isoforms probabilistically. The insert length distribution can be computed
    # by aligning read pairs to long, constitutive exons (like 3’ UTRs) and
    # measuring the distance between the read mates. The mean and standard
    # deviation of this distribution would then be given as arguments to
    # '--paired-end'. For example, to run on a paired-end sample where the mean
    # insert length is 250 and the standard deviation is 15, we would use:
    # '--paired-end 250 15' when calling miso (in addition to the '--run'
    # option).
    #
    # The '--overhang-len' option is not supported for paired-end reads.
    #
    # @seealso
    # - https://miso.readthedocs.io/en/fastmiso/
    # - http://hollywood.mit.edu/burgelab/miso/
    # - https://nf-co.re/rnasplice/
    # - https://github.com/nf-core/rnasplice/blob/master/modules/
    #     local/miso_run.nf
    # - https://github.com/nf-core/rnasplice/blob/master/modules/
    #     local/miso_index.nf
    # - https://github.com/jrflab/modules/blob/master/isoforms/miso.mk
    # """
    local -A app bool dict
    local -a miso_args
    app['index_gff']="$(koopa_locate_miso_index_gff)"
    app['miso']="$(koopa_locate_miso)"
    app['tee']="$(koopa_locate_tee --allow-system)"
    koopa_assert_is_executable "${app[@]}"
    bool['paired']=0
    # e.g. 'Aligned.sortedByCoord.out.bam'.
    dict['bam_file']=''
    # e.g. 'FIXME'.
    dict['genome_fasta_file']=''
    # e.g. 'FIXME'.
    dict['gtf_file']=''
    dict['index_dir']="$(koopa_tmp_dir_in_wd)"
    # Using salmon library type conventions here.
    dict['lib_type']='A'
    dict['num_proc']="$(koopa_cpu_count)"
    # e.g. 150.
    dict['read_length']=''
    # e.g. 'miso/star-gencode/treatment-vs-control'.
    dict['output_dir']=''
    # e.g. 250.
    dict['paired_ins_len_mean']=''
    # e.g. 15.
    dict['paired_ins_len_std_dev']=''
    # e.g. 'paired'.
    dict['read_type']=''
    while (("$#"))
    do
        case "$1" in
            # Required key-value pairs -----------------------------------------
            '--bam-file='*)
                dict['bam_file']="${1#*=}"
                shift 1
                ;;
            '--bam-file')
                dict['bam_file']="${2:?}"
                shift 2
                ;;
            '--genome-fasta-file='*)
                dict['genome_fasta_file']="${1#*=}"
                shift 1
                ;;
            '--genome-fasta-file')
                dict['genome_fasta_file']="${2:?}"
                shift 2
                ;;
            '--gtf-file='*)
                dict['gtf_file']="${1#*=}"
                shift 1
                ;;
            '--gtf-file')
                dict['gtf_file']="${2:?}"
                shift 2
                ;;
            '--output-dir='*)
                dict['output_dir']="${1#*=}"
                shift 1
                ;;
            '--output-dir')
                dict['output_dir']="${2:?}"
                shift 2
                ;;
            # Optional key-value pairs -----------------------------------------
            '--lib-type='*)
                dict['lib_type']="${1#*=}"
                shift 1
                ;;
            '--lib-type')
                dict['lib_type']="${2:?}"
                shift 2
                ;;
            '--read-length='*)
                dict['read_length']="${1#*=}"
                shift 1
                ;;
            '--read-length')
                dict['read_length']="${2:?}"
                shift 2
                ;;
            '--read-type='*)
                dict['read_type']="${1#*=}"
                shift 1
                ;;
            '--read-type')
                dict['read_type']="${2:?}"
                shift 2
                ;;
            # Other ------------------------------------------------------------
            *)
                koopa_invalid_arg "$1"
                ;;
        esac
    done
    koopa_assert_is_set \
        '--bam-file' "${dict['bam_file']}" \
        '--genome-fasta-file' "${dict['genome_fasta_file']}" \
        '--gtf-file' "${dict['gtf_file']}" \
        '--output-dir' "${dict['output_dir']}"
    koopa_assert_is_file \
        "${dict['bam_file']}" \
        "${dict['genome_fasta_file']}" \
        "${dict['gtf_file']}"
    koopa_assert_is_matching_regex \
        --pattern='\.bam$' \
        --string="${dict['bam_file']}"
    koopa_assert_is_not_dir "${dict['output_dir']}"
    dict['output_dir']="$(koopa_init_dir "${dict['output_dir']}")"
    dict['log_file']="${dict['output_dir']}/miso.log"
    dict['settings_file']="${dict['output_dir']}/settings.txt"
    koopa_alert "Running MISO analysis in '${dict['output_dir']}'."
    if [[ "${dict['lib_type']}" == 'A' ]]
    then
        koopa_alert 'Detecting BAM library type with salmon.'
        dict['lib_type']="$( \
            koopa_salmon_detect_bam_library_type \
                --bam-file="${dict['bam_file']}" \
                --fasta-file="${dict['genome_fasta_file']}" \
        )"
    fi
    dict['lib_type']="$( \
        koopa_salmon_library_type_to_miso "${dict['lib_type']}" \
    )"
    if [[ -z "${dict['read_length']}" ]]
    then
        koopa_alert 'Detecting BAM read length.'
        dict['read_length']="$(koopa_bam_read_length "${dict['bam_file']}")"
    fi
    if [[ -z "${dict['read_type']}" ]]
    then
        koopa_alert 'Detecting BAM read type.'
        dict['read_type']="$(koopa_bam_read_type "${dict['bam_file']}")"
    fi
    case "${dict['read_type']}" in
        'paired')
            bool['paired']=1
            ;;
        'single')
            ;;
        *)
            koopa_stop "Unsupported read type: '${dict['read_type']}'."
            ;;
    esac
    if [[ "${bool['paired']}" -eq 1 ]]
    then
        # FIXME Need to add suport for calc of these.
        dict['paired_ins_len_mean']='FIXME'
        dict['paired_ins_len_std_dev']='FIXME'
    fi
    read -r -d '' "dict[settings_string]" << END || true
[data]
filter_results = True
min_event_reads = 20
strand = ${dict['lib_type']}
END
    koopa_write_string \
        --file="${dict['settings_file']}" \
        --string="${dict['settings_string']}"
    koopa_alert "Generating MISO index in '${dict['index_dir']}'."
    "${app['index_gff']}" --index "${dict['gtf_file']}" "${dict['index_dir']}"
    miso_args+=(
        '--run' # COMPUTE_GENES_PSI
            "${dict['index_dir']}"
            "${dict['bam_file']}"
        '-p' "${dict['num_proc']}"
        '--output-dir' "${dict['output_dir']}"
        '--read-len' "${dict['read_length']}"
        '--settings-filename' "${dict['settings_file']}"
    )
    if [[ "${bool['paired']}" -eq 1 ]]
    then
        # FIXME Need to calculate these values here.
        miso_args+=(
            '--paired-end'
                "${dict['paired_ins_len_mean']}"
                "${dict['paired_ins_len_std_dev']}"
        )
    fi
    koopa_dl 'miso' "${miso_args[*]}"
    koopa_print "${app['miso']} ${miso_args[*]}" \
        >> "${dict['log_file']}"
    "${app['miso']}" "${miso_args[@]}" \
        |& "${app['tee']}" -a "${dict['log_file']}"
    return 0
}
