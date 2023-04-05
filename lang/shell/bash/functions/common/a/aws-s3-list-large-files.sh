#!/usr/bin/env bash

koopa_aws_s3_list_large_files() {
    # """
    # List large files in an S3 bucket.
    # @note Updated 2022-10-11.
    #
    # @examples
    # > koopa_aws_s3_list_large_files \
    # >     --profile='acidgenomics' \
    # >     --bucket='s3://r.acidgenomics.com/' \
    # >     --num=2
    # # testdata/bcbiornaseq/v0.5/bcb.rda
    # # testdata/bcbiornaseq/v0.5/gse65267.rds
    # """
    local app dict
    declare -A app dict
    koopa_assert_has_args "$#"
    app['awk']="$(koopa_locate_awk)"
    app['aws']="$(koopa_locate_aws)"
    app['jq']="$(koopa_locate_jq)"
    app['sort']="$(koopa_locate_sort)"
    [[ -x "${app['awk']}" ]] || exit 1
    [[ -x "${app['aws']}" ]] || exit 1
    [[ -x "${app['jq']}" ]] || exit 1
    [[ -x "${app['sort']}" ]] || exit 1
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
    koopa_assert_is_matching_regex \
        --pattern='^s3://.+/$' \
        --string="${dict['bucket']}"
    dict['bucket']="$( \
        koopa_sub \
            --pattern='s3://' \
            --replacement='' \
            "${dict['bucket']}" \
    )"
    dict['bucket']="$(koopa_strip_trailing_slash "${dict['bucket']}")"
    dict['awk_string']="NR<=${dict['num']} {print \$1}"
    # FIXME Specify that we want json from 'list-object-versions'.
    dict['str']="$( \
        "${app['aws']}" --profile="${dict['profile']}" \
            s3api list-object-versions \
                --bucket "${dict['bucket']}" \
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
