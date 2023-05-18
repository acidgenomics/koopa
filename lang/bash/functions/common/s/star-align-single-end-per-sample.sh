#!/usr/bin/env bash

# FIXME Add support for automatic pushing to AWS S3.

# NOTE Make sure our settings match GDC mRNA analysis pipeline:
# https://docs.gdc.cancer.gov/Data/Bioinformatics_Pipelines/Expression_mRNA_Pipeline/

koopa_star_align_single_end_per_sample() {
    # """
    # Run STAR aligner on a single-end sample.
    # @note Updated 2023-04-05.
    #
    # @examples
    # > koopa_star_align_single_end_per_sample \
    # >     --fastq-file='fastq/sample1_001.fastq.gz' \
    # >     --fastq-tail='_001.fastq.gz' \
    # >     --index-dir='star-index' \
    # >     --output-dir='star'
    # """
    local -A app dict
    local -a align_args
    koopa_assert_has_args "$#"
    app['star']="$(koopa_locate_star)"
    koopa_assert_is_executable "${app[@]}"
    # e.g. 'fastq'.
    dict['fastq_file']=''
    # e.g. '_001.fastq.gz'.
    dict['fastq_tail']=''
    # e.g. 'star-index'.
    dict['index_dir']=''
    dict['mem_gb']="$(koopa_mem_gb)"
    dict['mem_gb_cutoff']=60
    # e.g. 'star'.
    dict['output_dir']=''
    dict['threads']="$(koopa_cpu_count)"
    align_args=()
    while (("$#"))
    do
        case "$1" in
            # Key-value pairs --------------------------------------------------
            '--fastq-file='*)
                dict['fastq_file']="${1#*=}"
                shift 1
                ;;
            '--fastq-file')
                dict['fastq_file']="${2:?}"
                shift 2
                ;;
            '--fastq-tail='*)
                dict['fastq_tail']="${1#*=}"
                shift 1
                ;;
            '--fastq-tail')
                dict['fastq_tail']="${2:?}"
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
            # Other ------------------------------------------------------------
            *)
                koopa_invalid_arg "$1"
                ;;
        esac
    done
    koopa_assert_is_set \
        '--fastq-file' "${dict['fastq_file']}" \
        '--fastq-tail' "${dict['fastq_tail']}" \
        '--index-dir' "${dict['index_dir']}" \
        '--output-dir' "${dict['output_dir']}"
    if [[ "${dict['mem_gb']}" -lt "${dict['mem_gb_cutoff']}" ]]
    then
        koopa_stop "STAR 'alignReads' mode requires ${dict['mem_gb_cutoff']} \
GB of RAM."
    fi
    dict['limit_bam_sort_ram']=$(( dict['mem_gb'] * 1000000000 ))
    koopa_assert_is_dir "${dict['index_dir']}"
    dict['index_dir']="$(koopa_realpath "${dict['index_dir']}")"
    koopa_assert_is_file "${dict['fastq_file']}"
    dict['fastq_file']="$(koopa_realpath "${dict['fastq_file']}")"
    dict['fastq_bn']="$(koopa_basename "${dict['fastq_file']}")"
    dict['fastq_bn']="${dict['fastq_bn']/${dict['tail']}/}"
    dict['id']="${dict['fastq_bn']}"
    dict['output_dir']="${dict['output_dir']}/${dict['id']}"
    if [[ -d "${dict['output_dir']}" ]]
    then
        koopa_alert_note "Skipping '${dict['id']}'."
        return 0
    fi
    dict['output_dir']="$(koopa_init_dir "${dict['output_dir']}")"
    koopa_alert "Quantifying '${dict['id']}' in '${dict['output_dir']}'."
    dict['tmp_fastq_file']="$(koopa_tmp_file)"
    koopa_alert "Decompressing '${dict['fastq_file']}' \
to '${dict['tmp_fastq_file']}"
    koopa_decompress "${dict['fastq_file']}" "${dict['tmp_fastq_file']}"
    align_args+=(
        '--genomeDir' "${dict['index_dir']}"
        '--limitBAMsortRAM' "${dict['limit_bam_sort_ram']}"
        '--outFileNamePrefix' "${dict['output_dir']}/"
        '--outSAMtype' 'BAM' 'SortedByCoordinate'
        '--quantMode' 'TranscriptomeSAM'
        '--readFilesIn' "${dict['tmp_fastq_file']}"
        '--runMode' 'alignReads'
        '--runRNGseed' '0'
        '--runThreadN' "${dict['threads']}"
    )
    koopa_dl 'Align args' "${align_args[*]}"
    "${app['star']}" "${align_args[@]}"
    koopa_rm \
        "${dict['output_dir']}/_STAR"* \
        "${dict['tmp_fastq_file']}"
    return 0
}