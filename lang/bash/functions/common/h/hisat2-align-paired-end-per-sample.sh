#!/usr/bin/env bash

koopa_hisat2_align_paired_end_per_sample() {
    # """
    # Run HISAT2 aligner on a paired-end sample.
    # @note Updated 2023-10-20.
    #
    # @seealso
    # - hisat2 --help
    # - https://github.com/bcbio/bcbio-nextgen/blob/master/bcbio/ngsalign/
    #     hisat2.py
    # - https://daehwankimlab.github.io/hisat2/manual/
    #
    # @examples
    # > koopa_hisat2_align_paired_end_per_sample \
    # >     --fastq-r1-file='fastq/sample1_R1_001.fastq.gz' \
    # >     --fastq-r2-file='fastq/sample1_R2_001.fastq.gz' \
    # >     --index-dir='indexes/hisat2-gencode' \
    # >     --output-dir='quant/hisat2-gencode/sample1'
    # """
    local -A app bool dict
    local -a align_args
    app['hisat2']="$(koopa_locate_hisat2)"
    koopa_assert_is_executable "${app[@]}"
    bool['tmp_fastq_r1_file']=0
    bool['tmp_fastq_r2_file']=0
    # e.g. 'sample1_R1_001.fastq.gz'.
    dict['fastq_r1_file']=''
    # e.g. 'sample1_R2_001.fastq.gz'.
    dict['fastq_r2_file']=''
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
        '--fastq-r1-file' "${dict['fastq_r1_file']}" \
        '--fastq-r2-file' "${dict['fastq_r2_file']}" \
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
        '-1' "${dict['fastq_r1_file']}"
        '-2' "${dict['fastq_r2_file']}"
        '-S' "${dict['sam_file']}"
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
    "${app['hisat2']}" "${align_args[@]}"
    if [[ "${bool['tmp_fastq_r1_file']}" ]]
    then
        koopa_rm "${dict['fastq_r1_file']}"
    fi
    if [[ "${bool['tmp_fastq_r2_file']}" ]]
    then
        koopa_rm "${dict['fastq_r2_file']}"
    fi
    koopa_samtools_convert_sam_to_bam \
        --input-sam="${dict['sam_file']}" \
        --output-bam="${dict['bam_file']}"
    koopa_samtools_index_bam "${dict['bam_file']}"
    return 0
}
