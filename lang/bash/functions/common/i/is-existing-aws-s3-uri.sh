#!/usr/bin/env bash

# FIXME Need to define a function to get S3 bucket name.
# FIXME Need to define a function to get S3 key.

koopa_is_existing_aws_s3_uri() {
    # """
    # Does the input contain an AWS S3 URI that exists?
    # @note Updated 2023-11-03.
    #
    # @seealso
    # - https://www.learnaws.org/2023/01/30/aws-s3-cli-check-file/
    #
    # @examples
    # koopa_is_existing_aws_s3_uri \
    #     --profile='acidgenomics' \
    #     's3://koopa.acidgenomics.com/install'
    # """
    local -A app dict
    local -a pos
    local uri
    koopa_assert_has_args "$#"
    app['aws']="$(koopa_locate_aws)"
    koopa_assert_is_executable "${app[@]}"
    dict['profile']="${AWS_PROFILE:-default}"
    pos=()
    while (("$#"))
    do
        case "$1" in
            # Key-value pairs --------------------------------------------------
            '--profile='*)
                dict['profile']="${1#*=}"
                shift 1
                ;;
            '--profile')
                dict['profile']="${2:?}"
                shift 2
                ;;
            # Other ------------------------------------------------------------
            '-'*)
                koopa_invalid_arg "$1"
                ;;
            *)
                pos+=("$1")
                shift 1
                ;;
        esac
    done
    [[ "${#pos[@]}" -gt 0 ]] && set -- "${pos[@]}"
    koopa_assert_has_args "$#"
    koopa_is_aws_s3_uri "$@" || return 1
    for uri in "$@"
    do
        local -A dict2
        dict2['uri']="$uri"
        dict2['bucket']="$(koopa_aws_s3_bucket "${dict2['uri']}")"
        dict2['key']="$(koopa_aws_s3_key "${dict2['uri']}")"
        "${app['aws']}" --profile="${dict['profile']}" \
            s3api head-object \
            --bucket "${dict2['bucket']}" \
            --key "${dict2['key']}" \
            || return 1
        continue
    done
    return 0
}
