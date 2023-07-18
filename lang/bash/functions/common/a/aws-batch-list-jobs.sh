#!/usr/bin/env bash

koopa_aws_batch_list_jobs() {
    # """
    # List AWS Batch jobs.
    # @note Updated 2023-07-18.
    #
    # @seealso
    # - aws batch list-jobs help
    # """
    local -A app dict
    local -a job_queue_array status_array
    local status
    app['aws']="$(koopa_locate_aws)"
    koopa_assert_is_executable "${app[@]}"
    dict['account_id']="${AWS_BATCH_ACCOUNT_ID:-}"
    dict['profile']="${AWS_PROFILE:-default}"
    dict['queue']="${AWS_BATCH_QUEUE:-}"
    dict['region']="${AWS_BATCH_REGION:-}"
    while (("$#"))
    do
        case "$1" in
            # Key-value pairs --------------------------------------------------
            '--account-id='*)
                dict['account_id']="${1#*=}"
                shift 1
                ;;
            '--account-id')
                dict['account_id']="${2:?}"
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
            '--queue='*)
                dict['queue']="${1#*=}"
                shift 1
                ;;
            '--queue')
                dict['queue']="${2:?}"
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
        '--account-id or AWS_BATCH_ACCOUNT_ID' "${dict['account_id']}" \
        '--queue or AWS_BATCH_QUEUE' "${dict['queue']}" \
        '--region or AWS_BATCH_REGION' "${dict['region']}" \
        '--profile or AWS_PROFILE' "${dict['profile']}"
    koopa_h1 "Checking AWS Batch job status for '${dict['profile']}' profile."
    job_queue_array=(
        'arn'
        'aws'
        'batch'
        "${dict['region']}"
        "${dict['account_id']}"
        "job-queue/${dict['queue']}"
    )
    status_array=(
        'SUBMITTED'
        'PENDING'
        'RUNNABLE'
        'STARTING'
        'RUNNING'
        'SUCCEEDED'
        'FAILED'
    )
    dict['job_queue']="$(koopa_paste --sep=':' "${job_queue_array[@]}")"
    for status in "${status_array[@]}"
    do
        koopa_h2 "$status"
        "${app['aws']}" batch list-jobs \
            --job-queue "${dict['job_queue']}" \
            --job-status "$status" \
            --no-cli-pager \
            --output 'text' \
            --profile "${dict['profile']}"
    done
    return 0
}
