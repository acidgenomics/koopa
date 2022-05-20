#!/usr/bin/env bash

koopa_aws_s3_list_large_files() {
    # """
    # List large files in an S3 bucket.
    # @note Updated 2022-02-03.
    #
    # @examples
    # > koopa_aws_s3_list_large_files \
    # >     --profile='acidgenomics' \
    # >     --bucket='s3://r.acidgenomics.com/' \
    # >     --num=10
    # """
    local app dict
    koopa_assert_has_args "$#"
    declare -A app=(
        [awk]="$(koopa_locate_awk)"
        [aws]="$(koopa_locate_aws)"
        [jq]="$(koopa_locate_jq)"
        [sort]="$(koopa_locate_sort)"
        [tail]="$(koopa_locate_tail)"
    )
    declare -A dict=(
        [bucket]=''
        [num]='20'
        [profile]='acidgenomics'
    )
    while (("$#"))
    do
        case "$1" in
            # Key-value pairs --------------------------------------------------
            '--bucket='*)
                dict[bucket]="${1#*=}"
                shift 1
                ;;
            '--bucket')
                dict[bucket]="${2:?}"
                shift 2
                ;;
            '--num='*)
                dict[num]="${1#*=}"
                shift 1
                ;;
            '--num')
                dict[num]="${2:?}"
                shift 2
                ;;
            '--profile='*)
                dict[profile]="${1#*=}"
                shift 1
                ;;
            '--profile')
                dict[profile]="${2:?}"
                shift 2
                ;;
            # Other ------------------------------------------------------------
            *)
                koopa_invalid_arg "$1"
                ;;
        esac
    done
    koopa_assert_is_set \
        '--bucket' "${dict[bucket]}" \
        '--num' "${dict[num]}" \
        '--profile or AWS_PROFILE' "${dict[profile]}"
    koopa_assert_is_matching_regex \
        --pattern='^s3://.+/$' \
        --string="${dict[bucket]}"
    dict[bucket]="$( \
        koopa_sub \
            --pattern='s3://' \
            --replacement='' \
            "${dict[bucket]}" \
    )"
    dict[bucket]="$(koopa_strip_trailing_slash "${dict[bucket]}")"
    # shellcheck disable=SC2016
    dict[str]="$( \
        "${app[aws]}" --profile="${dict[profile]}" \
            s3api list-object-versions --bucket "${dict[bucket]}" \
            | "${app[jq]}" \
                --raw-output \
                '.Versions[] | "\(.Key)\t \(.Size)"' \
            | "${app[sort]}" --key=2 --numeric-sort \
            | "${app[awk]}" '{ print $1 }' \
            | "${app[tail]}" -n "${dict[num]}" \
    )"
    [[ -n "${dict[str]}" ]] || return 1
    koopa_print "${dict[str]}"
    return 0
}
