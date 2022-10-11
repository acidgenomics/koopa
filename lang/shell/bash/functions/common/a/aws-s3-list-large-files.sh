#!/usr/bin/env bash

koopa_aws_s3_list_large_files() {
    # """
    # List large files in an S3 bucket.
    # @note Updated 2022-10-11.
    #
    # @seealso
    # - Exit code 141 issue with head
    #   https://stackoverflow.com/questions/19120263/
    # - https://stackoverflow.com/questions/22464786/
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
    koopa_assert_has_args "$#"
    declare -A app=(
        ['awk']="$(koopa_locate_awk)"
        ['aws']="$(koopa_locate_aws)"
        ['head']="$(koopa_locate_head)"
        ['jq']="$(koopa_locate_jq)"
        ['sort']="$(koopa_locate_sort)"
    )
    [[ -x "${app['awk']}" ]] || return 1
    [[ -x "${app['aws']}" ]] || return 1
    [[ -x "${app['head']}" ]] || return 1
    [[ -x "${app['jq']}" ]] || return 1
    [[ -x "${app['sort']}" ]] || return 1
    declare -A dict=(
        ['bucket']=''
        ['num']='20'
        ['profile']="${AWS_PROFILE:-default}"
        ['region']="${AWS_REGION:-us-east-1}"
    )
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
    # NOTE We're intentionally suppressing pipefail exit code 141 in head
    # command step here.
    # shellcheck disable=SC2016
    dict['str']="$( \
        "${app['aws']}" --profile="${dict['profile']}" \
            s3api list-object-versions \
                --bucket "${dict['bucket']}" \
                --region "${dict['region']}" \
            | "${app['jq']}" \
                --raw-output \
                '.Versions[] | "\(.Key)\t \(.Size)"' \
            | "${app['sort']}" --key=2 --numeric-sort --reverse \
            | "${app['head']}" --lines="${dict['num']}" \
            | "${app['awk']}" '{ print $1 }' \
            || koopa_ignore_pipefail "$?" \
    )"
    [[ -n "${dict['str']}" ]] || return 1
    koopa_print "${dict['str']}"
    return 0
}
