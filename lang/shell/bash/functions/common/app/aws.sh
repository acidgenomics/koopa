#!/usr/bin/env bash

koopa_aws_batch_fetch_and_run() { # {{{1
    # """
    # Fetch and run a script on AWS Batch.
    # @note Updated 2022-01-20.
    #
    # S3 bucket paths and remote URLs are supported.
    #
    # @seealso
    # - https://github.com/FredHutch/url-fetch-and-run
    # - https://github.com/awslabs/aws-batch-helpers
    # """
    local app dict
    koopa_assert_has_no_args "$#"
    koopa_assert_is_set 'BATCH_FILE_URL' "${BATCH_FILE_URL:-}"
    declare -A app=(
        [aws]="$(koopa_locate_aws)"
    )
    declare -A dict=(
        [file]="$(koopa_tmp_file)"
        [profile]="${AWS_PROFILE:-}"
        [url]="${BATCH_FILE_URL:?}"
    )
    [[ -z "${dict[profile]}" ]] && dict[profile]='default'
    case "${dict[url]}" in
        'ftp'* | \
        'http'*)
            koopa_download "${dict[url]}" "${dict[file]}"
            ;;
        's3'*)
            "${app[aws]}" --profile="${dict[profile]}" \
                s3 cp "${dict[url]}" "${dict[file]}"
            ;;
        *)
            koopa_stop "Unsupported URL: '${dict[url]}'."
            ;;
    esac
    koopa_chmod 'u+x' "${dict[file]}"
    "${dict[file]}"
    return 0
}

koopa_aws_batch_list_jobs() { # {{{1
    # """
    # List AWS Batch jobs.
    # @note Updated 2021-11-05.
    # """
    local app dict job_queue_array status status_array
    local -A app=(
        [aws]="$(koopa_locate_aws)"
    )
    local -A dict=(
        [account_id]="${AWS_BATCH_ACCOUNT_ID:-}"
        [profile]="${AWS_PROFILE:-}"
        [queue]="${AWS_BATCH_QUEUE:-}"
        [region]="${AWS_BATCH_REGION:-}"
    )
    [[ -z "${dict[profile]}" ]] && dict[profile]='default'
    while (("$#"))
    do
        case "$1" in
            # Key-value pairs --------------------------------------------------
            '--account-id='*)
                dict[account_id]="${1#*=}"
                shift 1
                ;;
            '--account-id')
                dict[account_id]="${2:?}"
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
            '--queue='*)
                dict[queue]="${1#*=}"
                shift 1
                ;;
            '--queue')
                dict[queue]="${2:?}"
                shift 2
                ;;
            '--region='*)
                dict[region]="${1#*=}"
                shift 1
                ;;
            '--region')
                dict[region]="${2:?}"
                shift 2
                ;;
            # Other ------------------------------------------------------------
            *)
                koopa_invalid_arg "$1"
                ;;
        esac
    done
    koopa_assert_is_set \
        '--account-id or AWS_BATCH_ACCOUNT_ID' "${dict[account_id]:-}" \
        '--queue or AWS_BATCH_QUEUE' "${dict[queue]:-}" \
        '--region or AWS_BATCH_REGION' "${dict[region]:-}" \
        '--profile or AWS_PROFILE' "${dict[profile]:-}"
    koopa_h1 "Checking AWS Batch job status for '${dict[profile]}' profile."
    job_queue_array=(
        'arn'
        'aws'
        'batch'
        "${dict[region]}"
        "${dict[account_id]}"
        "job-queue/${dict[queue]}"
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

    dict[job_queue]="$(koopa_paste --sep=':' "${job_queue_array[@]}")"
    for status in "${status_array[@]}"
    do
        koopa_h2 "$status"
        "${app[aws]}" --profile="${dict[profile]}" \
            batch list-jobs \
                --job-queue "${dict[job_queue]}" \
                --job-status "$status"
    done
    return 0
}

# FIXME Work on adding support for this.
koopa_aws_ec2_create_instance() { # {{{1
    # """
    # Create an AWS EC2 instance.
    # @note Updated 2022-01-11.
    # """
    return 0
}

# FIXME Work on adding support for this.
koopa_aws_ec2_instance_id() { # {{{1
    # """
    # AWS EC2 instance identifier.
    # @note Updated 2022-01-11.
    # """
    return 0
}

# FIXME Work on adding support for this.
koopa_aws_ec2_suspend_instance() { # {{{1
    # """
    # Suspend an AWS EC2 instance.
    # @note Updated 2022-02-11.
    # """
    return 0
}

# FIXME Work on adding support for this.
koopa_aws_ec2_terminate_instance() { # {{{1
    # """
    # Terminate an AWS EC2 instance.
    # @note Updated 2022-02-11.
    # """
    return 0
}

koopa_aws_s3_cp_regex() { # {{{1
    # """
    # Copy a local file or S3 object to another location locally or in S3 using
    # regular expression pattern matching.
    #
    # @note Updated 2022-02-23.
    #
    # @seealso
    # - aws s3 cp help
    # """
    local app dict
    koopa_assert_has_args "$#"
    declare -A app=(
        [aws]="$(koopa_locate_aws)"
    )
    declare -A dict=(
        [pattern]=''
        [profile]="${AWS_PROFILE:-}"
        [source_prefix]=''
        [target_prefix]=''
    )
    [[ -z "${dict[profile]}" ]] && dict[profile]='default'
    while (("$#"))
    do
        case "$1" in
            # Key-value pairs --------------------------------------------------
            '--pattern='*)
                dict[pattern]="${1#*=}"
                shift 1
                ;;
            '--pattern')
                dict[pattern]="${2:?}"
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
            '--source_prefix='*)
                dict[source_prefix]="${1#*=}"
                shift 1
                ;;
            '--source_prefix')
                dict[source_prefix]="${2:?}"
                shift 2
                ;;
            '--target_prefix='*)
                dict[target_prefix]="${1#*=}"
                shift 1
                ;;
            '--target_prefix')
                dict[target_prefix]="${2:?}"
                shift 2
                ;;
            # Other ------------------------------------------------------------
            *)
                koopa_invalid_arg "$1"
                ;;
        esac
    done
    koopa_assert_is_set \
        '--pattern' "${dict[pattern]}" \
        '--profile or AWS_PROFILE' "${dict[profile]}" \
        '--source-prefix' "${dict[source_prefix]}" \
        '--target-prefix' "${dict[target_prefix]}"
    "${app[aws]}" --profile="${dict[profile]}" \
        s3 cp \
            --exclude='*' \
            --follow-symlinks \
            --include="${dict[pattern]}" \
            --recursive \
            "${dict[source_prefix]}" \
            "${dict[target_prefix]}"
    return 0
}

# FIXME Need to harden against user input, ensure they put in pattern here.
koopa_aws_s3_find() { # {{{1
    # """
    # Find files in an AWS S3 bucket.
    #
    # @note Updated 2022-02-23.
    #
    # @seealso
    # - https://docs.aws.amazon.com/cli/latest/reference/s3/
    #
    # @examples
    # > koopa_aws_s3_find \
    # >     --include='*.bw$' \
    # >     --exclude='antisense' \
    # >     's3://bioinfo/igv/'
    # """
    local dict pos str
    koopa_assert_has_args "$#"
    declare -A dict=(
        [exclude]=''
        [include]=''
        [profile]="${AWS_PROFILE:-}"
    )
    [[ -z "${dict[profile]}" ]] && dict[profile]='default'
    pos=()
    while (("$#"))
    do
        case "$1" in
            # Key-value pairs --------------------------------------------------
            '--exclude='*)
                dict[exclude]="${1#*=}"
                shift 1
                ;;
            '--exclude')
                dict[exclude]="${2:?}"
                shift 2
                ;;
            '--include='*)
                dict[include]="${1#*=}"
                shift 1
                ;;
            '--include')
                dict[include]="${2:?}"
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
    str="$( \
        koopa_aws_s3_ls \
        --profile="${dict[profile]}" \
        --recursive \
        "$@" \
    )"
    if [[ -z "$str" ]]
    then
        koopa_stop 'Failed to recursively list any files.'
    fi
    # Exclude pattern.
    if [[ -n "${dict[exclude]}" ]]
    then
        str="$( \
            koopa_grep \
                --extended-regexp \
                --invert-match \
                --pattern="${dict[exclude]}" \
                --string="$str" \
        )"
        if [[ -z "$str" ]]
        then
            koopa_stop "No files left with '--exclude' argument."
        fi
    fi
    # Include pattern.
    if [[ -n "${dict[include]}" ]]
    then
        str="$( \
            koopa_grep \
                --extended-regexp \
                --pattern="${dict[include]}" \
                --string="$str" \
        )"
        if [[ -z "$str" ]]
        then
            koopa_stop "No files left with '--include' argument."
        fi
    fi
    koopa_print "$str"
    return 0
}

koopa_aws_s3_list_large_files() { # {{{1
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
        '--profile' "${dict[profile]}"
    dict[bucket]="$( \
        koopa_sub \
            --pattern='s3://' \
            --replacement='' \
            "${dict[bucket]}" \
    )"
    dict[bucket]="$(koopa_strip_trailing_slash "${dict[bucket]}")"
    dict[str]="$( \
        "${app[aws]}" --profile="${dict[profile]}" \
            s3api list-object-versions --bucket "${dict[bucket]}" \
            | "${app[jq]}" --raw-output '.Versions[] | "\(.Key)\t \(.Size)"' \
            | "${app[sort]}" --key=2 --numeric-sort \
            | "${app[tail]}" --lines="${dict[num]}" \
    )"
    [[ -n "${dict[str]}" ]] || return 1
    koopa_print "${dict[str]}"
    return 0
}

# FIXME Rework flags here.
# FIXME Rework 'x' as 'str' here.
# FIXME Rework grep calls here.

koopa_aws_s3_ls() { # {{{1
    # """
    # List an AWS S3 bucket.
    # @note Updated 2022-02-23.
    #
    # @seealso
    # - aws s3 ls help
    #
    # @examples
    # > prefix='s3://r.acidgenomics.com/src/contrib/'
    #
    # # Files and directories (default):
    # > koopa_aws_s3_ls "$prefix"
    #
    # # Files only:
    # > koopa_aws_s3_ls --type='f' "$prefix"
    #
    # # Directories only:
    # > koopa_aws_s3_ls --type='d' "$prefix"
    # """
    local app dict ls_args pos str
    declare -A app=(
        [awk]="$(koopa_locate_awk)"
        [aws]="$(koopa_locate_aws)"
        [sed]="$(koopa_locate_sed)"
    )
    declare -A dict=(
        [prefim]='s3://'
        [profile]="${AWS_PROFILE:-}"
        [recursive]=0
        [type]=''
    )
    [[ -z "${dict[profile]}" ]] && dict[profile]='default'
    ls_args=()
    pos=()
    while (("$#"))
    do
        case "$1" in
            # Key-value pairs --------------------------------------------------
            '--prefix='*)
                dict[prefix]="${1#*=}"
                shift 1
                ;;
            '--prefix')
                dict[prefix]="${2:?}"
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
            '--type='*)
                dict[type]="${1#*=}"
                shift 1
                ;;
            '--type')
                dict[type]="${2:?}"
                shift 2
                ;;
            # Flags ------------------------------------------------------------
            '--recursive')
                dict[recursive]=1
                shift 1
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
    if [[ "$#" -gt 0 ]]
    then
        koopa_assert_has_args_eq "$#" 1
        dict[prefix]="${1:?}"
    fi
    # Don't allow '--type' argument when '--recursive' flag is set.
    if [[ "${dict[recursive]}" -eq 1 ]] && \
        [[ -n "${dict[type]}" ]]
    then
        koopa_stop "'--type' argument not supported for '--recursive' mode."
    fi
    case "${dict[type]}" in
        'd')
            dict[dirs]=1
            dict[files]=0
            ;;
        'f')
            dict[dirs]=0
            dict[files]=1
            ;;
        '')
            dict[dirs]=1
            dict[files]=1
            ;;
        *)
            koopa_stop "Unsupported type: '${dict[type]}'."
            ;;
    esac
    [[ "${dict[recursive]}" -eq 1 ]] && ls_args+=('--recursive')
    if [[ "${dict[prefix]}" != 's3://' ]]
    then
        dict[prefix]="$(koopa_strip_trailing_slash "${dict[prefix]}")"
        dict[prefix]="${dict[prefix]}/"
    fi
    # Automatically add 's3://' if missing.
    if ! koopa_str_detect_regex \
        --string="${dict[prefix]}" \
        --pattern='^s3://'
    then
        dict[prefix]="s3://${dict[prefix]}"
    fi
    str="$( \
        "${app[aws]}" --profile="${dict[profile]}" \
            s3 ls "${ls_args[@]}" "${dict[prefix]}" \
    )"
    if [[ "$#" -eq 0 ]]
    then
        koopa_print "$str"
    fi
    # Recursive mode. Note that in this mode, 'aws s3 ls' returns the full path
    # after the bucket name.
    if [[ "${dict[recursive]}" -eq 1 ]]
    then
        dict[bucket_prefix]="$( \
            koopa_grep \
                --extended-regexp \
                --only-matching \
                --pattern='^s3://[^/]+' \
                --string="${dict[prefix]}" \
        )"
        files="$( \
            koopa_grep \
                --extended-regexp \
                --pattern='^[0-9]{4}-[0-9]{2}-[0-9]{2}' \
                --string="$str" \
            || true \
        )"
        [[ -n "$files" ]] || return 0
        files="$( \
            # shellcheck disable=SC2016
            koopa_print "$files" \
                | "${app[awk]}" '{print $4}' \
                | "${app[awk]}" 'NF' \
                | "${app[sed]}" "s|^|${dict[bucket_prefix]}/|g" \
        )"
        koopa_print "$files"
        return 0
    fi
    # Directories.
    if [[ "${dict[dirs]}" -eq 1 ]]
    then
        dirs="$( \
            koopa_grep \
                --extended-regexp \
                --only-matching \
                --pattern='^\s+PRE\s.+/$' \
                --string="$str" \
            || true \
        )"
        if [[ -n "$dirs" ]]
        then
            dirs="$( \
                koopa_print "$dirs" \
                    | "${app[sed]}" 's|^ \+PRE ||g' \
                    | "${app[awk]}" 'NF' \
                    | "${app[sed]}" "s|^|${dict[prefix]}|g" \
            )"
            koopa_print "$dirs"
        fi
    fi
    # Files.
    if [[ "${dict[files]}" -eq 1 ]]
    then
        files="$( \
            koopa_grep \
                --extended-regexp \
                --pattern='^[0-9]{4}-[0-9]{2}-[0-9]{2}' \
                --string="$str" \
            || true \
        )"
        if [[ -n "$files" ]]
        then
            # shellcheck disable=SC2016
            files="$( \
                koopa_print "$files" \
                    | "${app[awk]}" '{print $4}' \
                    | "${app[awk]}" 'NF' \
                    | "${app[sed]}" "s|^|${dict[prefix]}|g" \
            )"
            koopa_print "$files"
        fi
    fi
    return 0
}

koopa_aws_s3_mv_to_parent() { # {{{1
    # """
    # Move objects in an S3 bucket directory to parent directory.
    #
    # @note Updated 2022-02-23.
    #
    # @details
    # Empty directory will be removed automatically, since S3 uses object
    # storage.
    # """
    local app dict pos
    local file files prefix
    koopa_assert_has_args "$#"
    declare -A app=(
        [aws]="$(koopa_locate_aws)"
    )
    declare -A dict=(
        [profile]="${AWS_PROFILE:-}"
    )
    [[ -z "${dict[profile]}" ]] && dict[profile]='default'
    pos=()
    while (("$#"))
    do
        case "$1" in
            # Key-value pairs --------------------------------------------------
            '--prefix='*)
                dict[prefix]="${1#*=}"
                shift 1
                ;;
            '--prefix')
                dict[prefix]="${2:?}"
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
    if [[ "$#" -gt 0 ]]
    then
        koopa_assert_has_args_eq "$#" 1
        dict[prefix]="${1:?}"
    fi
    koopa_assert_is_set \
        '--profile or AWS_PROFILE' "${dict[profile]:-}"
        '--prefix' "${dict[prefix]:-}"
    dict[str]="$( \
        koopa_aws_s3_ls \
            --prefix="${dict[prefix]}" \
            --profile="${dict[profile]}" \
    )"
    if [[ -z "${dict[str]}" ]]
    then
        koopa_stop "Failed to list any files in '${dict[prefix]}'."
    fi
    readarray -t files <<< "${dict[str]}"
    for file in "${files[@]}"
    do
        local dict2
        declare -A dict2=(
            [bn]="$(koopa_basename "$file")"
            [dn1]="$(koopa_dirname "$file")"
        )
        dict2[dn2]="$(koopa_dirname "${dict2[dn1]}")"
        dict2[target]="${dict2[dn2]}/${dict2[bn]}"
        "${app[aws]}" --profile="${dict[profile]}" \
            s3 mv "${dict2[file]}" "${dict2[target]}"
    done
    return 0
}

# FIXME Better programmatic access example:
# > aws s3api list-buckets --output 'json'
# > aws s3api list-objects \
# >     --output 'json' \
# >     --bucket 'koopa.acidgenomics.com'
# FIXME Exclusion of directories isn't working correctly.
# FIXME Need to add a mode that excludes all files that are under git in a
# current directory. This will help avoid duplication of source code.
# FIXME Consider ignoring all files managed under git by default.
# These files are returned by 'git ls-files'.
# See also:
# - https://superuser.com/questions/429693
# FIXME Consider naming this option '--ignore-git'.
# This should only apply when source is local, and target is 's3://...'.
# FIXME This needs to support '--exclude' and '--include' more intuitively.
# FIXME If '--exclude=*' is set, we need to rethink our default exclude flags.

koopa_aws_s3_sync() { # {{{1
    # """
    # Sync an S3 bucket, but ignore some files automatically.
    # @note Updated 2021-11-05.
    #
    # @details
    # AWS CLI unfortunately does not currently support regular expressions, at
    # least as of v2.0.8.
    #
    # Pattern matching reference:
    # - https://docs.aws.amazon.com/cli/latest/reference/s3/
    #       #use-of-exclude-and-include-filters
    # - https://github.com/aws/aws-cli/issues/476
    # - https://stackoverflow.com/questions/36215713/
    #
    # Nuclear dotfile option: --exclude='.*'
    # Otherwise, can manually ignore '.git', '.gitignore', etc.
    #
    # Currently ignores:
    # - Invisible dot files, prefixed with '.'.
    # - Temporary files.
    # - '*.Rproj' directories.
    # - '*.swp' files (from vim).
    # """
    local aws dict exclude_args exclude_patterns pattern pos sync_args
    koopa_assert_has_args "$#"
    declare -A app=(
        [aws]="$(koopa_locate_aws)"
    )
    declare -A dict=(
        [profile]="${AWS_PROFILE:-}"
    )
    [[ -z "${dict[profile]}" ]] && dict[profile]='default'
    # Include common file system and Git cruft that we don't want on S3.
    # FIXME Only set this if the user doesn't pass in exclude?
    exclude_patterns=(
        '*.Rproj/*'
        '*.swp'
        '*.tmp'
        '.*'
        '.DS_Store'
        '.Rproj.user/*'
        '._*'
        '.git/*'
    )
    pos=()
    sync_args=()
    while (("$#"))
    do
        case "$1" in
            # Key-value pairs --------------------------------------------------
            '--exclude='*)
                exclude_patterns+=("${1#*=}")
                shift 1
                ;;
            '--exclude')
                exclude_patterns+=("${2:?}")
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
            '--source-prefix='*)
                dict[source_prefix]="${1#*=}"
                shift 1
                ;;
            '--source-prefix')
                dict[source_prefix]="${2:?}"
                shift 2
                ;;
            '--target-prefix='*)
                dict[target_prefix]="${1#*=}"
                shift 1
                ;;
            '--target-prefix')
                dict[target_prefix]="${2:?}"
                shift 2
                ;;
            # Flags ------------------------------------------------------------
            '--delete' | \
            '--dryrun' | \
            '--exact-timestamps' | \
            '--follow-symlinks' | \
            '--no-follow-symlinks' | \
            '--no-progress' | \
            '--only-show-errors' | \
            '--size-only' | \
            '--quiet')
                sync_args+=("$1")
                shift 1
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
    if [[ "$#" -gt 0 ]]
    then
        koopa_assert_has_args_eq "$#" 2
        sync_args+=("$@")
    else
        sync_args+=(
            "${dict[source_prefix]}"
            "${dict[target_prefix]}"
        )
    fi
    exclude_args=()
    for pattern in "${exclude_patterns[@]}"
    do
        exclude_args+=(
            "--exclude=${pattern}"
            "--exclude=*/${pattern}"
        )
    done
    "${app[aws]}" --profile="${dict[profile]}" \
        s3 sync \
            "${exclude_args[@]}" \
            "${sync_args[@]}"
    return 0
}
