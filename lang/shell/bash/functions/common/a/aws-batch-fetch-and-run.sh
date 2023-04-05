#!/usr/bin/env bash

koopa_aws_batch_fetch_and_run() {
    # """
    # Fetch and run a script on AWS Batch.
    # @note Updated 2023-02-15.
    #
    # S3 bucket paths and remote URLs are supported.
    #
    # @seealso
    # - https://github.com/FredHutch/url-fetch-and-run
    # - https://github.com/awslabs/aws-batch-helpers
    # """
    local -A app dict
    koopa_assert_has_no_args "$#"
    koopa_assert_is_set 'BATCH_FILE_URL' "${BATCH_FILE_URL:-}"
    app['aws']="$(koopa_locate_aws)"
    [[ -x "${app['aws']}" ]] || exit 1
    dict['file']="$(koopa_tmp_file)"
    dict['profile']="${AWS_PROFILE:-default}"
    dict['url']="${BATCH_FILE_URL:?}"
    case "${dict['url']}" in
        'ftp://'* | \
        'http://'*)
            koopa_download "${dict['url']}" "${dict['file']}"
            ;;
        's3://'*)
            "${app['aws']}" --profile="${dict['profile']}" \
                s3 cp "${dict['url']}" "${dict['file']}"
            ;;
        *)
            koopa_stop "Unsupported URL: '${dict['url']}'."
            ;;
    esac
    koopa_chmod 'u+x' "${dict['file']}"
    "${dict['file']}"
    return 0
}
