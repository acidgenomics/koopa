#!/usr/bin/env bash

koopa_aws_s3_list_large_files() {
    # """
    # List large files in an S3 bucket.
    # @note Updated 2025-05-08.
    #
    # @examples
    # > koopa_aws_s3_list_large_files \
    # >     --profile='acidgenomics' \
    # >     --bucket='s3://r.acidgenomics.com/' \
    # >     --num=2
    # # testdata/bcbiornaseq/v0.5/bcb.rda
    # # testdata/bcbiornaseq/v0.5/gse65267.rds
    # """
    local -A app dict
    koopa_assert_has_args "$#"
    app['awk']="$(koopa_locate_awk)"
    app['aws']="$(koopa_locate_aws)"
    app['jq']="$(koopa_locate_jq)"
    app['sort']="$(koopa_locate_sort)"
    koopa_assert_is_executable "${app[@]}"
    dict['bucket']=''
    dict['num']='20'
    dict['profile']="${AWS_PROFILE:-default}"
    dict['region']="${AWS_REGION:-us-east-1}"
    while (("$#"))
    do
        case "$1" in
            # Key-value pairs --------------------------------------------------
            '--bucket='*)
                dict['bucket']="${1#*=}"
                shift 1
                ;;
            '--bucket')
                dict['bucket']="${2:?}"
                shift 2
                ;;
            '--num='*)
                dict['num']="${1#*=}"
                shift 1
                ;;
            '--num')
                dict['num']="${2:?}"
                shift 2
                ;;
            '--profile='*)
                dict['profile']="${1#*=}"
                shift 1
                ;;
            '--profile')
                dict['profile']="${2:?}"
                shift 2
                ;;
            '--region='*)
                dict['region']="${1#*=}"
                shift 1
                ;;
            '--region')
                dict['region']="${2:?}"
                shift 2
                ;;
            # Other ------------------------------------------------------------
            *)
                koopa_invalid_arg "$1"
                ;;
        esac
    done
    koopa_assert_is_set \
        '--bucket' "${dict['bucket']}" \
        '--num' "${dict['num']}" \
        '--profile or AWS_PROFILE' "${dict['profile']}" \
        '--region or AWS_REGION' "${dict['region']}"
    dict['bucket']="$( \
        koopa_sub \
            --pattern='s3://' \
            --replacement='' \
            "${dict['bucket']}" \
    )"
    dict['bucket']="$(koopa_strip_trailing_slash "${dict['bucket']}")"
    dict['awk_string']="NR<=${dict['num']} {print \$1}"
    dict['str']="$( \
        "${app['aws']}" s3api list-object-versions \
            --bucket "${dict['bucket']}" \
            --output 'json' \
            --profile "${dict['profile']}" \
            --region "${dict['region']}" \
        | "${app['jq']}" \
            --raw-output \
            '.Versions[] | "\(.Key)\t \(.Size)"' \
        | "${app['sort']}" --key=2 --numeric-sort --reverse \
        | "${app['awk']}" "${dict['awk_string']}" \
    )"
    [[ -n "${dict['str']}" ]] || return 1
    koopa_print "${dict['str']}"
    return 0
}
