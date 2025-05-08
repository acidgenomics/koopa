#!/usr/bin/env bash

# FIXME Consider adding 'miso_pack --pack my_output1/' step at the end
# to compress the output.
# FIXME Write output to temporary directory and then locate '.miso_summary' files instead
# so we can standardize the output.
#
# FIXME Consider adding 'summarize_miso --summarize-samples my_output2/ summaries/' into
# the target output directory?

koopa_miso_run() {
    # """
    # Run MISO splicing event analysis.
    # @note Updated 2023-11-20.
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
    # by aligning read pairs to long, constitutive exons (like 3' UTRs) and
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
    koopa_activate_app_conda_env 'misopy'
    # Using our bedtools and samtools instead of the bundled variants in the
    # misopy conda recipe, due to broken 'libncurses.so.5'.
    koopa_activate_app 'bedtools' 'samtools'
    app['cut']="$(koopa_locate_cut --allow-system)"
    app['head']="$(koopa_locate_head --allow-system)"
    app['miso']="$(koopa_locate_miso --realpath)"
    app['pe_utils']="$(koopa_locate_miso_pe_utils --realpath)"
    app['tee']="$(koopa_locate_tee --allow-system)"
    koopa_assert_is_executable "${app[@]}"
    bool['paired']=0
    # e.g. 'Aligned.sortedByCoord.out.bam'.
    dict['bam_file']=''
    # e.g. 'GRCh38.primary_assembly.genome.fa.gz'.
    dict['genome_fasta_file']=''
    dict['index_dir']=''
    # Using salmon library type conventions here.
    dict['lib_type']='A'
    dict['mem_gb']="$(koopa_mem_gb)"
    dict['mem_gb_cutoff']=14
    dict['num_proc']="$(koopa_cpu_count)"
    # e.g. 150.
    dict['read_length']=''
    # e.g. 'miso/star-gencode/treatment-vs-control'.
    dict['output_dir']=''
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
            '--index-dir='*)
                dict['index_dir']="${1#*=}"
                shift 1
                ;;
            '--index-dir')
                dict['index_dir']="${2:?}"
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
        '--index-dir' "${dict['index_dir']}" \
        '--output-dir' "${dict['output_dir']}"
    if [[ "${dict['mem_gb']}" -lt "${dict['mem_gb_cutoff']}" ]]
    then
        koopa_stop "MISO requires ${dict['mem_gb_cutoff']} GB of RAM."
    fi
    koopa_assert_is_dir "${dict['index_dir']}"
    koopa_assert_is_file \
        "${dict['bam_file']}" \
        "${dict['bam_file']}.bai" \
        "${dict['genome_fasta_file']}"
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
    # Refer to '/opt/koopa/opt/misopy/libexec/lib/python2.7/site-packages/
    # misopy/settings/miso_settings.txt' for default values.
    read -r -d '' "dict[settings_string]" << END || true
[data]
filter_results = True
min_event_reads = 20
strand = ${dict['lib_type']}

[cluster]
cluster_command = qsub

[sampler]
burn_in = 500
lag = 10
num_iters = 5000
num_chains = 6
num_processors = ${dict['num_proc']}
END
    koopa_write_string \
        --file="${dict['settings_file']}" \
        --string="${dict['settings_string']}"
    miso_args+=(
        '--run' "${dict['index_dir']}" "${dict['bam_file']}"
        '-p' "${dict['num_proc']}"
        '--output-dir' "${dict['output_dir']}"
        '--read-len' "${dict['read_length']}"
        '--settings-filename' "${dict['settings_file']}"
    )
    if [[ "${bool['paired']}" -eq 1 ]]
    then
        dict['exons_gff_file']="$( \
            koopa_find \
                --max-depth=1 \
                --min-depth=1 \
                --pattern='*.const_exons.gff' \
                --prefix="${dict['index_dir']}" \
                --type='f' \
        )"
        koopa_assert_is_file "${dict['exons_gff_file']}"
        dict['min_exon_size']=500
        dict['tmp_insert_dist_dir']="$(koopa_tmp_dir_in_wd)"
        "${app['pe_utils']}" \
            --compute-insert-len \
                "${dict['bam_file']}" \
                "${dict['exons_gff_file']}" \
            --min-exon-size="${dict['min_exon_size']}" \
            --output-dir "${dict['tmp_insert_dist_dir']}"
        dict['insert_length_file']="$( \
            koopa_find \
                --hidden \
                --max-depth=1 \
                --min-depth=1 \
                --pattern='*.insert_len' \
                --prefix="${dict['tmp_insert_dist_dir']}" \
                --type='f' \
        )"
        koopa_assert_is_file "${dict['insert_length_file']}"
        dict['insert_length_mean']="$( \
            "${app['head']}" -n 1 "${dict['insert_length_file']}" \
                | "${app['cut']}" -d ',' -f 1 \
                | "${app['cut']}" -d '=' -f 2 \
        )"
        dict['insert_length_sdev']="$( \
            "${app['head']}" -n 1 "${dict['insert_length_file']}" \
                | "${app['cut']}" -d ',' -f 2 \
                | "${app['cut']}" -d '=' -f 2 \
        )"
        miso_args+=(
            '--paired-end'
                "${dict['insert_length_mean']}"
                "${dict['insert_length_sdev']}"
        )
        koopa_rm "${dict['tmp_insert_dist_dir']}"
    fi
    koopa_dl 'miso' "${miso_args[*]}"
    koopa_print "${app['miso']} ${miso_args[*]}" >> "${dict['log_file']}"
    "${app['miso']}" "${miso_args[@]}" \
        |& "${app['tee']}" -a "${dict['log_file']}"
    return 0
}
