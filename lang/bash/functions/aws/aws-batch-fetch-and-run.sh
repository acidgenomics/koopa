#!/usr/bin/env bash

_koopa_aws_batch_fetch_and_run() {
    # """
    # Fetch and run a script on AWS Batch.
    # @note Updated 2023-07-18.
    #
    # S3 bucket paths and remote URLs are supported.
    #
    # @seealso
    # - https://github.com/FredHutch/url-fetch-and-run
    # - https://github.com/awslabs/aws-batch-helpers
    # """
    local -A app dict
    _koopa_assert_has_no_args "$#"
    _koopa_assert_is_set 'BATCH_FILE_URL' "${BATCH_FILE_URL:-}"
    app['aws']="$(_koopa_locate_aws)"
    _koopa_assert_is_executable "${app[@]}"
    dict['file']="$(_koopa_tmp_file)"
    dict['profile']="${AWS_PROFILE:-default}"
    dict['url']="${BATCH_FILE_URL:?}"
    case "${dict['url']}" in
        'ftp://'* | \
        'http://'*)
            _koopa_download "${dict['url']}" "${dict['file']}"
            ;;
        's3://'*)
            "${app['aws']}" s3 cp \
                --profile "${dict['profile']}" \
                "${dict['url']}" "${dict['file']}"
            ;;
        *)
            _koopa_stop "Unsupported URL: '${dict['url']}'."
            ;;
    esac
    _koopa_chmod 'u+x' "${dict['file']}"
    "${dict['file']}"
    return 0
}
