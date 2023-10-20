#!/usr/bin/env bash

# TODO Add support for FASTQ directory directly from S3.
# TODO Add support for genome index tarball directly from S3.

koopa_kallisto_quant_paired_end() {
    # """
    # Run kallisto quant on multiple paired-end FASTQs in a directory.
    # @note Updated 2023-10-20.
    #
    # @examples
    # > koopa_kallisto_quant_paired_end \
    # >     --fastq-dir='fastq' \
    # >     --fastq-r1-tail='_R1_001.fastq.gz' \
    # >     --fastq-r2-tail='_R2_001.fastq.gz' \
    # >     --index-dir='indexes/kallisto-gencode' \
    # >     --output-dir='quant/kallisto-gencode'
    # """
    local -A app bool dict
    local -a fastq_r1_files
    local fastq_r1_file
    koopa_assert_has_args "$#"
    bool['aws_s3_output_dir']=0
    bool['tmp_output_dir']=0
    # e.g. 'fastq'.
    dict['fastq_dir']=''
    # e.g. '_R1_001.fastq.gz'.
    dict['fastq_r1_tail']=''
    # e.g. "_R2_001.fastq.gz'
    dict['fastq_r2_tail']=''
    # e.g. 'indexes/kallisto-gencode'.
    dict['index_dir']=''
    # Using salmon fragment library type conventions here.
    dict['lib_type']='A'
    # e.g. 'quant/kallisto-gencode'.
    dict['output_dir']=''
    while (("$#"))
    do
        case "$1" in
            # Key-value pairs --------------------------------------------------
            '--aws-profile='*)
                dict['aws_profile']="${1#*=}"
                shift 1
                ;;
            '--aws-profile')
                dict['aws_profile']="${2:?}"
                shift 2
                ;;
            '--fastq-dir='*)
                dict['fastq_dir']="${1#*=}"
                shift 1
                ;;
            '--fastq-dir')
                dict['fastq_dir']="${2:?}"
                shift 2
                ;;
            '--fastq-r1-tail='*)
                dict['fastq_r1_tail']="${1#*=}"
                shift 1
                ;;
            '--fastq-r1-tail')
                dict['fastq_r1_tail']="${2:?}"
                shift 2
                ;;
            '--fastq-r2-tail='*)
                dict['fastq_r2_tail']="${1#*=}"
                shift 1
                ;;
            '--fastq-r2-tail')
                dict['fastq_r2_tail']="${2:?}"
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
        '--fastq-dir' "${dict['fastq_dir']}" \
        '--fastq-r1-tail' "${dict['fastq_r1_tail']}" \
        '--fastq-r2-tail' "${dict['fastq_r1_tail']}" \
        '--index-dir' "${dict['index_dir']}" \
        '--lib-type' "${dict['lib_type']}" \
        '--output-dir' "${dict['output_dir']}"
    koopa_assert_is_dir "${dict['fastq_dir']}" "${dict['index_dir']}"
    dict['fastq_dir']="$(koopa_realpath "${dict['fastq_dir']}")"
    dict['index_dir']="$(koopa_realpath "${dict['index_dir']}")"
    if koopa_is_aws_s3_uri "${dict['output_dir']}"
    then
        bool['aws_s3_output_dir']=1
        bool['tmp_output_dir']=1
        dict['aws_s3_output_dir']="$( \
            koopa_strip_trailing_slash "${dict['output_dir']}" \
        )"
        dict['output_dir']="$(koopa_tmp_dir_in_wd)"
    fi
    if [[ "${bool['aws_s3_output_dir']}" -eq 1 ]]
    then
        app['aws']="$(koopa_locate_aws --allow-system)"
        koopa_assert_is_executable "${app['aws']}"
    fi
    dict['output_dir']="$(koopa_init_dir "${dict['output_dir']}")"
    koopa_h1 'Running kallisto quant.'
    koopa_dl \
        'Mode' 'paired-end' \
        'Index dir' "${dict['index_dir']}" \
        'FASTQ dir' "${dict['fastq_dir']}" \
        'FASTQ R1 tail' "${dict['fastq_r1_tail']}" \
        'FASTQ R2 tail' "${dict['fastq_r2_tail']}" \
        'Output dir' "${dict['output_dir']}"
    if [[ "${bool['aws_s3_output_dir']}" -eq 1 ]]
    then
        koopa_dl 'AWS S3 output dir' "${dict['aws_s3_output_dir']}"
    fi
    readarray -t fastq_r1_files <<< "$( \
        koopa_find \
            --max-depth=1 \
            --min-depth=1 \
            --pattern="*${dict['fastq_r1_tail']}" \
            --prefix="${dict['fastq_dir']}" \
            --sort \
    )"
    if koopa_is_array_empty "${fastq_r1_files[@]:-}"
    then
        koopa_stop "No FASTQs ending with '${dict['fastq_r1_tail']}'."
    fi
    koopa_assert_is_file "${fastq_r1_files[@]}"
    koopa_alert_info "$(koopa_ngettext \
        --num="${#fastq_r1_files[@]}" \
        --msg1='sample' \
        --msg2='samples' \
        --suffix=' detected.' \
    )"
    for fastq_r1_file in "${fastq_r1_files[@]}"
    do
        local -A dict2
        dict2['fastq_r1_file']="$fastq_r1_file"
        dict2['fastq_r2_file']="${dict2['fastq_r1_file']/\
${dict['fastq_r1_tail']}/${dict['fastq_r2_tail']}}"
        dict2['sample_id']="$(koopa_basename "${dict2['fastq_r1_file']}")"
        dict2['sample_id']="${dict2['sample_id']/${dict['fastq_r1_tail']}/}"
        dict2['output_dir']="${dict['output_dir']}/${dict2['sample_id']}"
        koopa_kallisto_quant_paired_end_per_sample \
            --fastq-r1-file="${dict2['fastq_r1_file']}" \
            --fastq-r2-file="${dict2['fastq_r2_file']}" \
            --index-dir="${dict['index_dir']}" \
            --lib-type="${dict['lib_type']}" \
            --output-dir="${dict2['output_dir']}"
    done
    if [[ "${bool['tmp_output_dir']}" -eq 1 ]]
    then
        koopa_rm "${dict['output_dir']}"
    fi
    koopa_alert_success 'kallisto quant was successful.'
    return 0
}
