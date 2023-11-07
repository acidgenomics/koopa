#!/usr/bin/env bash

koopa_hisat2_align_single_end_per_sample() {
    # """
    # Run HISAT2 aligner on a single-end sample.
    # @note Updated 2023-10-23.
    #
    # @examples
    # > koopa_hisat2_align_single_end_per_sample \
    # >     --fastq-file='fastq/sample1_001.fastq.gz' \
    # >     --index-dir='indexes/hisat2-gencode' \
    # >     --output-dir='quant/hisat2-gencode/sample1'
    # """
    local -A app bool dict
    local -a align_args
    koopa_assert_has_args "$#"
    app['hisat2']="$(koopa_locate_hisat2)"
    app['tee']="$(koopa_locate_tee --allow-system)"
    koopa_assert_is_executable "${app[@]}"
    bool['tmp_fastq_file']=0
    # e.g. 'sample1_001.fastq.gz'.
    dict['fastq_file']=''
    # e.g. 'indexes/hisat2-gencode'.
    dict['index_dir']=''
    # Using salmon fragment library type conventions here.
    dict['lib_type']='A'
    dict['mem_gb']="$(koopa_mem_gb)"
    dict['mem_gb_cutoff']=14
    # e.g. 'quant/hisat2-gencode/sample1'.
    dict['output_dir']=''
    dict['threads']="$(koopa_cpu_count)"
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
            # Other ------------------------------------------------------------
            *)
                koopa_invalid_arg "$1"
                ;;
        esac
    done
    koopa_assert_is_set \
        '--fastq-file' "${dict['fastq_file']}" \
        '--index-dir' "${dict['index_dir']}" \
        '--lib-type' "${dict['lib_type']}" \
        '--output-dir' "${dict['output_dir']}"
    if [[ -d "${dict['output_dir']}" ]]
    then
        koopa_alert_note "Skipping '${dict['output_dir']}'."
        return 0
    fi
    if [[ "${dict['mem_gb']}" -lt "${dict['mem_gb_cutoff']}" ]]
    then
        koopa_stop "HISAT2 align requires ${dict['mem_gb_cutoff']} GB of RAM."
    fi
    koopa_assert_is_dir "${dict['index_dir']}"
    dict['index_dir']="$(koopa_realpath "${dict['index_dir']}")"
    dict['hisat2_idx']="${dict['index_dir']}/index"
    koopa_assert_is_file "${dict['fastq_file']}"
    dict['fastq_file']="$(koopa_realpath "${dict['fastq_file']}")"
    dict['fastq_bn']="$(koopa_basename "${dict['fastq_file']}")"
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
    koopa_alert "Quantifying '${dict['fastq_bn']}' in '${dict['output_dir']}'."
    if koopa_is_compressed_file "${dict['fastq_file']}"
    then
        bool['tmp_fastq_file']=1
        dict['tmp_fastq_file']="$(koopa_tmp_file_in_wd --ext='fastq')"
        koopa_decompress \
            --input-file="${dict['fastq_file']}" \
            --output-file="${dict['tmp_fastq_file']}"
        dict['fastq_file']="${dict['tmp_fastq_file']}"
    fi
    align_args+=(
        '-S' "${dict['sam_file']}"
        '-U' "${dict['fastq_file']}"
        '-q'
        '-x' "${dict['hisat2_idx']}"
        '--new-summary'
        '--threads' "${dict['threads']}"
    )
    dict['lib_type']="$(koopa_hisat2_fastq_library_type "${dict['lib_type']}")"
    if [[ -n "${dict['lib_type']}" ]]
    then
        align_args+=('--rna-strandedness' "${dict['lib_type']}")
    fi
    dict['quality_flag']="$( \
        koopa_hisat2_fastq_quality_format "${dict['fastq_r1_file']}" \
    )"
    if [[ -n "${dict['quality_flag']}" ]]
    then
        align_args+=("${dict['quality_flag']}")
    fi
    koopa_dl 'Align args' "${align_args[*]}"
    "${app['hisat2']}" "${align_args[@]}" \
        2>&1 | "${app['tee']}" "${dict['log_file']}"
    if [[ "${bool['tmp_fastq_r1_file']}" -eq 1 ]]
    then
        koopa_rm "${dict['fastq_r1_file']}"
    fi
    if [[ "${bool['tmp_fastq_r2_file']}" -eq 1 ]]
    then
        koopa_rm "${dict['fastq_r2_file']}"
    fi
    koopa_samtools_convert_sam_to_bam "${dict['sam_file']}"
    koopa_samtools_sort_bam "${dict['bam_file']}"
    koopa_samtools_index_bam "${dict['bam_file']}"
    return 0
}
