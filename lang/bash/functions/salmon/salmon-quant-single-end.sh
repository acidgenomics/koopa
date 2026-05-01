#!/usr/bin/env bash

# TODO Add support for FASTQ directory directly from S3.
# TODO Add support for genome index tarball directly from S3.

_koopa_salmon_quant_single_end() {
    # """
    # Run salmon quant on multiple single-end FASTQs in a directory.
    # @note Updated 2023-10-20.
    #
    # @examples
    # > _koopa_salmon_quant_single_end \
    # >     --fastq-dir='fastq' \
    # >     --fastq-tail='_001.fastq.gz' \
    # >     --index-dir='indexes/salmon-gencode' \
    # >     --output-dir='quant/salmon-gencode'
    # """
    local -A app bool dict
    local -a fastq_files
    local fastq_file
    _koopa_assert_has_args "$#"
    bool['aws_s3_output_dir']=0
    bool['tmp_output_dir']=0
    dict['aws_profile']="${AWS_PROFILE:-default}"
    # e.g. 'fastq'.
    dict['fastq_dir']=''
    # e.g. '.fastq.gz'.
    dict['fastq_tail']=''
    # e.g. 'salmon-index'.
    dict['index_dir']=''
    # Detect library fragment type (strandedness) automatically.
    dict['lib_type']='A'
    # e.g. 'salmon', or AWS S3 URI 's3://example/quant/salmon-gencode'.
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
                _koopa_invalid_arg "$1"
                ;;
        esac
    done
    _koopa_assert_is_set \
        '--fastq-dir' "${dict['fastq_dir']}" \
        '--fastq-tail' "${dict['fastq_tail']}" \
        '--index-dir' "${dict['index_dir']}" \
        '--lib-type' "${dict['lib_type']}" \
        '--output-dir' "${dict['output_dir']}"
    _koopa_assert_is_dir "${dict['fastq_dir']}" "${dict['index_dir']}"
    dict['fastq_dir']="$(_koopa_realpath "${dict['fastq_dir']}")"
    dict['index_dir']="$(_koopa_realpath "${dict['index_dir']}")"
    if _koopa_is_aws_s3_uri "${dict['output_dir']}"
    then
        bool['aws_s3_output_dir']=1
        bool['tmp_output_dir']=1
        dict['aws_s3_output_dir']="$( \
            _koopa_strip_trailing_slash "${dict['output_dir']}" \
        )"
        dict['output_dir']="$(_koopa_tmp_dir_in_wd)"
    fi
    if [[ "${bool['aws_s3_output_dir']}" -eq 1 ]]
    then
        app['aws']="$(_koopa_locate_aws --allow-system)"
        _koopa_assert_is_executable "${app['aws']}"
    fi
    dict['output_dir']="$(_koopa_init_dir "${dict['output_dir']}")"
    _koopa_h1 'Running salmon quant.'
    _koopa_dl \
        'Mode' 'single-end' \
        'Index dir' "${dict['index_dir']}" \
        'FASTQ dir' "${dict['fastq_dir']}" \
        'FASTQ tail' "${dict['fastq_tail']}" \
        'Output dir' "${dict['output_dir']}"
    if [[ "${bool['aws_s3_output_dir']}" -eq 1 ]]
    then
        _koopa_dl 'AWS S3 output dir' "${dict['aws_s3_output_dir']}"
    fi
    readarray -t fastq_files <<< "$( \
        _koopa_find \
            --max-depth=1 \
            --min-depth=1 \
            --pattern="*${dict['fastq_tail']}" \
            --prefix="${dict['fastq_dir']}" \
            --sort \
    )"
    if _koopa_is_array_empty "${fastq_files[@]:-}"
    then
        _koopa_stop "No FASTQs ending with '${dict['fastq_tail']}'."
    fi
    _koopa_assert_is_file "${fastq_files[@]}"
    _koopa_alert_info "$(_koopa_ngettext \
        --num="${#fastq_files[@]}" \
        --msg1='sample' \
        --msg2='samples' \
        --suffix=' detected.' \
    )"
    for fastq_file in "${fastq_files[@]}"
    do
        local -A dict2
        dict2['fastq_file']="$fastq_file"
        dict2['sample_id']="$( \
            _koopa_sub \
                --pattern="${dict['fastq_tail']}\$" \
                --regex \
                --replacement='' \
                "$(_koopa_basename "${dict2['fastq_file']}")" \
        )"
        dict2['output_dir']="${dict['output_dir']}/${dict2['sample_id']}"
        _koopa_salmon_quant_single_end_per_sample \
            --fastq-file="${dict2['fastq_file']}" \
            --index-dir="${dict['index_dir']}" \
            --lib-type="${dict['lib_type']}" \
            --output-dir="${dict2['output_dir']}"
        if [[ "${bool['aws_s3_output_dir']}" -eq 1 ]]
        then
            dict2['aws_s3_output_dir']="${dict['aws_s3_output_dir']}/\
${dict2['sample_id']}"
            _koopa_alert "Syncing '${dict2['output_dir']}' to \
'${dict2['aws_s3_output_dir']}'."
            "${app['aws']}" s3 sync \
                --profile "${dict['aws_profile']}" \
                "${dict2['output_dir']}/" \
                "${dict2['aws_s3_output_dir']}/"
            _koopa_rm "${dict2['output_dir']}"
            _koopa_mkdir "${dict2['output_dir']}"
        fi
    done
    if [[ "${bool['tmp_output_dir']}" -eq 1 ]]
    then
        _koopa_rm "${dict['output_dir']}"
    fi
    _koopa_alert_success 'salmon quant was successful.'
    return 0
}
