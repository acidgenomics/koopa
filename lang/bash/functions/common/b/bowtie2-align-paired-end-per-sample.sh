#!/usr/bin/env bash

koopa_bowtie2_align_paired_end_per_sample() {
    # """
    # Run bowtie2 alignment on multiple paired-end FASTQ files.
    # @note Updated 2023-10-23.
    # """
    local -A app bool dict
    koopa_assert_has_args "$#"
    app['bowtie2']="$(koopa_locate_bowtie2)"
    app['tee']="$(koopa_locate_tee --allow-system)"
    koopa_assert_is_executable "${app[@]}"
    bool['tmp_fastq_r1_file']=0
    bool['tmp_fastq_r2_file']=0
    # e.g. 'sample1_R1_001.fastq.gz'.
    dict['fastq_r1_file']=''
    # e.g. 'sample1_R2_001.fastq.gz'.
    dict['fastq_r2_file']=''
    # e.g. 'indexes/bowtie2-gencode'.
    dict['index_dir']=''
    # e.g. 'quant/bowtie2-gencode/sample1'.
    dict['mem_gb']="$(koopa_mem_gb)"
    dict['mem_gb_cutoff']=14
    dict['output_dir']=''
    dict['threads']="$(koopa_cpu_count)"
    while (("$#"))
    do
        case "$1" in
            # Key-value pairs --------------------------------------------------
            '--fastq-r1-file='*)
                dict['fastq_r1_file']="${1#*=}"
                shift 1
                ;;
            '--fastq-r1-file')
                dict['fastq_r1_file']="${2:?}"
                shift 2
                ;;
            '--fastq-r2-file='*)
                dict['fastq_r2_file']="${1#*=}"
                shift 1
                ;;
            '--fastq-r2-file')
                dict['fastq_r2_file']="${2:?}"
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
        '--fastq-r1-file' "${dict['fastq_r1_file']}" \
        '--fastq-r2-file' "${dict['fastq_r2_file']}" \
        '--index-dir' "${dict['index_dir']}" \
        '--output-dir' "${dict['output_dir']}"
    if [[ -d "${dict['output_dir']}" ]]
    then
        koopa_alert_note "Skipping '${dict['output_dir']}'."
        return 0
    fi
    if [[ "${dict['mem_gb']}" -lt "${dict['mem_gb_cutoff']}" ]]
    then
        koopa_stop "bowtie2 requires ${dict['mem_gb_cutoff']} GB of RAM."
    fi
    koopa_assert_is_dir "${dict['index_dir']}"
    dict['index_dir']="$(koopa_realpath "${dict['index_dir']}")"
    dict['index_base']="${dict['index_dir']}/bowtie2"
    koopa_assert_is_file "${dict['fastq_r1_file']}" "${dict['fastq_r2_file']}"
    dict['fastq_r1_file']="$(koopa_realpath "${dict['fastq_r1_file']}")"
    dict['fastq_r2_file']="$(koopa_realpath "${dict['fastq_r2_file']}")"
    dict['fastq_r1_bn']="$(koopa_basename "${dict['fastq_r1_file']}")"
    dict['fastq_r2_bn']="$(koopa_basename "${dict['fastq_r2_file']}")"
    dict['output_dir']="$(koopa_init_dir "${dict['output_dir']}")"
    dict['sample_bn']="$(koopa_basename "${dict['output_dir']}")"
    dict['sam_file']="${dict['output_dir']}/${dict['sample_bn']}.sam"
    dict['bam_file']="$( \
        koopa_sub \
            --pattern='\.sam$' \
            --regex \
            --replacement='.bam' \
            "${dict['sam_file']}" \
    )"
    dict['log_file']="$( \
        koopa_sub \
            --pattern='\.sam$' \
            --regex \
            --replacement='.log' \
            "${dict['sam_file']}" \
    )"
    koopa_alert "Quantifying '${dict['fastq_r1_bn']}' and \
'${dict['fastq_r2_bn']}' in '${dict['output_dir']}'."
    if koopa_is_compressed_file "${dict['fastq_r1_file']}"
    then
        bool['tmp_fastq_r1_file']=1
        dict['tmp_fastq_r1_file']="$(koopa_tmp_file_in_wd)"
        koopa_alert "Decompressing '${dict['fastq_r1_file']}' to \
'${dict['tmp_fastq_r1_file']}"
        koopa_decompress \
            "${dict['fastq_r1_file']}" \
            "${dict['tmp_fastq_r1_file']}"
        dict['fastq_r1_file']="${dict['tmp_fastq_r1_file']}"
    fi
    if koopa_is_compressed_file "${dict['fastq_r2_file']}"
    then
        bool['tmp_fastq_r2_file']=1
        dict['tmp_fastq_r2_file']="$(koopa_tmp_file_in_wd)"
        koopa_alert "Decompressing '${dict['fastq_r2_file']}' to \
'${dict['tmp_fastq_r2_file']}"
        koopa_decompress \
            "${dict['fastq_r2_file']}" \
            "${dict['tmp_fastq_r2_file']}"
        dict['fastq_r2_file']="${dict['tmp_fastq_r2_file']}"
    fi
    align_args+=(
        '--local'
        '--sensitive-local'
        '--rg-id' "${dict['id']}"
        '--rg' 'PL:illumina'
        '--rg' "PU:${dict['id']}"
        '--rg' "SM:${dict['id']}"
        '--threads' "${dict['threads']}"
        '-1' "${dict['fastq_r1_file']}"
        '-2' "${dict['fastq_r2_file']}"
        '-S' "${dict['sam_file']}"
        '-X' 2000
        '-q'
        '-x' "${dict['index_base']}"
    )
    koopa_dl 'Align args' "${align_args[*]}"
    "${app['bowtie2']}" "${align_args[@]}" \
        2>&1 | "${app['tee']}" "${dict['log_file']}"
    if [[ "${bool['tmp_fastq_r1_file']}" ]]
    then
        koopa_rm "${dict['fastq_r1_file']}"
    fi
    if [[ "${bool['tmp_fastq_r2_file']}" ]]
    then
        koopa_rm "${dict['fastq_r2_file']}"
    fi
    koopa_samtools_convert_sam_to_bam "${dict['sam_file']}"
    koopa_samtools_sort_bam "${dict['bam_file']}"
    koopa_samtools_index_bam "${dict['bam_file']}"
    return 0
}
