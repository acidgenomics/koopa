#!/usr/bin/env bash

# FIXME Add support for finding and downloading FASTQs direct from S3.
# FIXME Add support for AWS S3 URI index-dir.
#   For the index dir, need to copy and extract to a standardized file path.
#   To do this, we need to update 'koopa_extract' with this functionality.

koopa_star_align_paired_end() {
    # """
    # Run STAR aligner on multiple paired-end FASTQs in a directory.
    # @note Updated 2023-04-06.
    #
    # @examples
    # > koopa_star_align_paired_end \
    # >     --fastq-dir='fastq' \
    # >     --fastq-r1-tail='_R1_001.fastq.gz' \
    # >     --fastq-r2-tail='_R2_001.fastq.gz' \
    # >     --index-dir='star-index' \
    # >     --output-dir='star'
    # """
    local -A dict
    local -a fastq_r1_files
    local fastq_r1_file
    koopa_assert_has_args "$#"
    dict['aws_profile']="${AWS_PROFILE:-default}"
    # e.g. 'fastq'.
    dict['fastq_dir']=''
    # e.g. '_R1_001.fastq.gz'.
    dict['fastq_r1_tail']=''
    # e.g. '_R2_001.fastq.gz'.
    dict['fastq_r2_tail']=''
    # e.g. 'star-index'.
    dict['index_dir']=''
    dict['mode']='paired-end'
    # e.g. 'star', or AWS S3 URI.
    dict['output_dir']=''
    # e.g. 's3://example/quant/star-gencode'.
    dict['output_s3_uri']=''
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
        '--output-dir' "${dict['output_dir']}"
    # FIXME Rework this to support S3 URIs.
    koopa_assert_is_dir "${dict['fastq_dir']}" "${dict['index_dir']}"
    dict['fastq_dir']="$(koopa_realpath "${dict['fastq_dir']}")"
    # FIXME Alternatively, support a compressed archive and decompress on the
    # fly here.
    dict['index_dir']="$(koopa_realpath "${dict['index_dir']}")"
    # FIXME Make this a function: 'koopa_is_aws_s3_uri'.
    if koopa_str_detect_fixed \
        --pattern='s3://' \
        --string="${dict['output_dir']}"
    then
        # FIXME Rework this approach, need to rethink if we're supporting
        # AWS FASTQ files and AWS index tarball.
        dict['output_s3_uri']="$( \
            koopa_strip_trailing_slash "${dict['output_dir']}" \
        )"
        dict['output_dir']="$(koopa_tmp_dir_in_wd)"
    fi
    dict['output_dir']="$(koopa_init_dir "${dict['output_dir']}")"
    koopa_h1 'Running STAR aligner.'
    koopa_dl \
        'Mode' "${dict['mode']}" \
        'Index dir' "${dict['index_dir']}" \
        'FASTQ dir' "${dict['fastq_dir']}" \
        'FASTQ R1 tail' "${dict['fastq_r1_tail']}" \
        'FASTQ R2 tail' "${dict['fastq_r2_tail']}" \
        'Output dir' "${dict['output_dir']}"

    if [[ -n "${dict['output_s3_uri']}" ]]
    then
        koopa_dl 'Output S3 URI' "${dict['output_s3_uri']}"
    fi
    readarray -t fastq_r1_files <<< "$( \
        koopa_find \
            --max-depth=1 \
            --min-depth=1 \
            --pattern="*${dict['fastq_r1_tail']}" \
            --prefix="${dict['fastq_dir']}" \
            --sort \
            --type='f' \
    )"
    if koopa_is_array_empty "${fastq_r1_files[@]:-}"
    then
        koopa_stop "No FASTQs ending with '${dict['fastq_r1_tail']}'."
    fi
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
        dict2['output_s3_uri']="${dict['output_s3_uri']}/${dict2['sample_id']}"
        koopa_star_align_paired_end_per_sample \
            --aws-profile="${dict['aws_profile']}" \
            --fastq-r1-file="${dict2['fastq_r1_file']}" \
            --fastq-r2-file="${dict2['fastq_r2_file']}" \
            --index-dir="${dict['index_dir']}" \
            --output-dir="${dict2['output_dir']}" \
            --output-s3-uri="${dict2['output_s3_uri']}"
        # FIXME Just pust the amazon stuff here instead...simpler.
        # FIXME And don't need to keep track of aws profile in the runner
        # function then too, that's nice.
    done
    [[ -n "${dict['aws_s3_uri']}" ]] && koopa_rm "${dict['output_dir']}"
    koopa_alert_success 'STAR alignment was successful.'
    return 0
}
