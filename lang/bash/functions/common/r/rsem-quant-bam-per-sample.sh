#!/usr/bin/env bash

koopa_rsem_quant_paired_end_per_sample() {
    # """
    # Quantify paired-end samples with RSEM.
    # @note Updated 2023-11-16.
    #
    # RSEM is optimized to use aligned reads from STAR, HISAT2, or Bowtie 2.
    # Note that Bowtie 2 is not splice aware.
    #
    # Can use '--alignments' mode to quantify from BAM/CRAM/SAM, or the '--bam'
    # option tells RSEM the input is a BAM file, instead of a pair of FASTQs.
    #
    # '--estimate-rspd' enabls RSEM to learn from data how the reads are
    # distributed across a transcript.
    #
    # @seealso
    # - https://deweylab.github.io/RSEM/rsem-calculate-expression.html
    # - https://github.com/bli25/RSEM_tutorial
    # - https://github.com/bcbio/bcbio-nextgen/blob/master/bcbio/rnaseq/rsem.py
    # """
    local -A app dict
    local -a quant_args
    app['rsem_calculate_expression']="$(koopa_locate_rsem_calculate_expression)"
    koopa_assert_is_executable "${app[@]}"
    # e.g. 'sample1.bam'.
    dict['bam_file']=''
    # Using salmon library conventions here.
    dict['lib_type']='A'
    dict['mem_gb']="$(koopa_mem_gb)"
    dict['mem_gb_cutoff']=14
    dict['threads']="$(koopa_cpu_count)"
    # e.g. 'gencode.v44.transcripts_fixed.fa.gz'.
    dict['transcriptome_fasta_file']=''
    while (("$#"))
    do
        case "$1" in
            # Key-value pairs --------------------------------------------------
            '--bam-file='*)
                dict['bam_file']="${1#*=}"
                shift 1
                ;;
            '--bam-file')
                dict['bam_file']="${2:?}"
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
            '--lib-type='*)
                dict['lib_type']="${1#*=}"
                shift 1
                ;;
            '--lib-type')
                dict['lib_type']="${2:?}"
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
            '--transcriptome-fasta-file='*)
                dict['transcriptome_fasta_file']="${1#*=}"
                shift 1
                ;;
            '--transcriptome-fasta-file')
                dict['transcriptome_fasta_file']="${2:?}"
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
        '--index-dir' "${dict['index_dir']}" \
        '--lib-type' "${dict['lib_type']}" \
        '--output-dir' "${dict['output_dir']}" \
        '--transcriptome-fasta-file' "${dict['transcriptome_fasta_file']}"
    if [[ -d "${dict['output_dir']}" ]]
    then
        koopa_alert_note "Skipping '${dict['output_dir']}'."
        return 0
    fi
    if [[ "${dict['mem_gb']}" -lt "${dict['mem_gb_cutoff']}" ]]
    then
        koopa_stop "RSEM quant requires ${dict['mem_gb_cutoff']} GB of RAM."
    fi
    koopa_assert_is_file "${dict['bam_file']}"
    koopa_assert_is_dir "${dict['index_dir']}"
    dict['bam_file']="$(koopa_realpath "${dict['bam_file']}")"
    koopa_assert_is_matching_regex \
        --pattern='\.bam$' \
        --string="${dict['bam_file']}"
    dict['bam_bn']="$(koopa_basename "${dict['bam_file']}")"
    dict['index_dir']="$(koopa_realpath "${dict['index_dir']}")"
    dict['output_dir']="$(koopa_init_dir "${dict['output_dir']}")"
    koopa_alert "Quantifying '${dict['bam_bn']}' in '${dict['output_dir']}'."
    if [[ "${dict['lib_type']}" == 'A' ]]
    then
        koopa_alert 'Detecting BAM library type with salmon.'
        dict['lib_type']="$( \
            koopa_salmon_detect_bam_library_type \
                --bam-file="${dict['bam_file']}" \
                --fasta-file="${dict['transcriptome_fasta_file']}" \
        )"
    fi
    dict['lib_type']="$( \
        koopa_salmon_library_type_to_rsem "${dict['lib_type']}" \
    )"
    koopa_alert 'Detecting BAM read type.'
    dict['read_type']="$(koopa_bam_read_type "${dict['bam_file']}")"
    case "${dict['read_type']}" in
        'paired')
            quant_args+=('--paired-end')
            ;;
        'single')
            ;;
        *)
            koopa_stop "Unsupported read type: '${dict['read_type']}'."
            ;;
    esac
    quant_args+=(
        '--bam'
        '--estimate-rspd'
        '--no-bam-output'
        '--num-threads' "${dict['threads']}"
        '--strandedness' "${dict['lib_type']}"
        "${dict['index_dir']}"
        "${dict['bam_file']}"
    )
    koopa_dl 'Quant args' "${quant_args[*]}"
    "${app['rsem_calculate_expression']}" "${quant_args[@]}"
    return 0
}
