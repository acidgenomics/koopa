#!/usr/bin/env bash

# FIXME Exclusion of directories isn't working correctly.
# FIXME Need to add a mode that excludes all files that are under git in a
# current directory. This will help avoid duplication of source code.

# Better programmatic access:
# > aws s3api list-buckets --output json
# > aws s3api list-objects \
# >     --output json \
# >     --bucket koopa.acidgenomics.com

koopa::aws_batch_fetch_and_run() { # {{{1
    # """
    # Fetch and run a script on AWS Batch.
    # @note Updated 2021-11-05.
    #
    # S3 bucket paths and remote URLs are supported.
    #
    # @seealso
    # - https://github.com/FredHutch/url-fetch-and-run
    # - https://github.com/awslabs/aws-batch-helpers
    # """
    local app dict
    koopa::assert_has_no_args "$#"
    koopa::assert_is_set 'BATCH_FILE_URL' "${BATCH_FILE_URL:-}"
    declare -A app=(
        [aws]="$(koopa::locate_aws)"
    )
    declare -A dict=(
        [file]="$(koopa::tmp_file)"
        [profile]="${AWS_PROFILE:-}"
        [url]="${BATCH_FILE_URL:?}"
    )
    [[ -z "${dict[profile]}" ]] && dict[profile]='default'
    case "${dict[url]}" in
        'ftp'* | \
        'http'*)
            koopa::download "${dict[url]}" "${dict[file]}"
            ;;
        's3'*)
            "$aws" --profile="${dict[profile]}" \
                s3 cp "${dict[url]}" "${dict[file]}"
            ;;
        *)
            koopa::stop "Unsupported URL: '${dict[url]}'."
            ;;
    esac
    koopa::chmod 'u+x' "${dict[file]}"
    "${dict[file]}"
    return 0
}

koopa::aws_batch_list_jobs() { # {{{1
    # """
    # List AWS Batch jobs.
    # @note Updated 2021-11-05.
    # """
    local app dict job_queue_array status status_array
    local -A app=(
        [aws]="$(koopa::locate_aws)"
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
                koopa::invalid_arg "$1"
                ;;
        esac
    done
    koopa::assert_is_set \
        '--account-id or AWS_BATCH_ACCOUNT_ID' "${dict[account_id]:-}" \
        '--queue or AWS_BATCH_QUEUE' "${dict[queue]:-}" \
        '--region or AWS_BATCH_REGION' "${dict[region]:-}" \
        '--profile or AWS_PROFILE' "${dict[profile]:-}"
    koopa::h1 "Checking AWS Batch job status for '${dict[profile]}' profile."
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

    dict[job_queue]="$(koopa::paste --sep=':' "${job_queue_array[@]}")"
    for status in "${status_array[@]}"
    do
        koopa::h2 "$status"
        "${app[aws]}" --profile="${dict[profile]}" \
            batch list-jobs \
                --job-queue "${dict[job_queue]}" \
                --job-status "$status"
    done
    return 0
}

koopa::aws_cp_regex() { # {{{1
    # """
    # Copy a local file or S3 object to another location locally or in S3 using
    # regular expression pattern matching.
    #
    # @note Updated 2021-11-05.
    #
    # @seealso
    # - aws s3 cp help
    # """
    local app dict pos
    koopa::assert_has_args "$#"
    declare -A app=(
        [aws]="$(koopa::locate_aws)"
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
            '--pattern='*)
                pattern="${1#*=}"
                shift 1
                ;;
            '--pattern')
                pattern="${2:?}"
                shift 2
                ;;
            '--profile='*)
                profile="${1#*=}"
                shift 1
                ;;
            '--profile')
                profile="${2:?}"
                shift 2
                ;;
            '--source_prefix='*)
                source_prefix="${1#*=}"
                shift 1
                ;;
            '--source_prefix')
                source_prefix="${2:?}"
                shift 2
                ;;
            '--target_prefix='*)
                target_prefix="${1#*=}"
                shift 1
                ;;
            '--target_prefix')
                target_prefix="${2:?}"
                shift 2
                ;;
            # Other ------------------------------------------------------------
            *)
                koopa::invalid_arg "$1"
                ;;
        esac
    done
    koopa::assert_is_set \
        '--pattern' "${dict[pattern]:-}" \
        '--profile or AWS_PROFILE' "${dict[profile]:-}" \
        '--source-prefix' "${dict[source_prefix]:-}" \
        '--target-prefix' "${dict[target_prefix]:-}"
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

koopa::aws_s3_find() { # {{{1
    # """
    # Find files in an AWS S3 bucket.
    #
    # @note Updated 2021-11-05.
    #
    # @seealso
    # - https://docs.aws.amazon.com/cli/latest/reference/s3/
    #
    # @examples
    # koopa::aws_s3_find \
    #     --include='*.bw$' \
    #     --exclude='antisense' \
    #     's3://bioinfo/igv/'
    # """
    local dict pos x
    koopa::assert_has_args "$#"
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
                koopa::invalid_arg "$1"
                ;;
            *)
                pos+=("$1")
                shift 1
                ;;
        esac
    done
    [[ "${#pos[@]}" -gt 0 ]] && set -- "${pos[@]}"
    x="$( \
        koopa::aws_s3_ls \
        --profile="${dict[profile]}" \
        --recursive \
        "$@" \
    )"
    if [[ -z "$x" ]]
    then
        koopa::warn 'Failed to recursively list any files.'
        return 1
    fi
    # Exclude pattern.
    if [[ -n "${dict[exclude]}" ]]
    then
        x="$( \
            koopa::print "$x" \
                | koopa::grep \
                    --extended-regexp \
                    --invert-match \
                    "${dict[exclude]}" \
        )"
        if [[ -z "$x" ]]
        then
            koopa::warn "No files left with '--exclude' argument."
            return 1
        fi
    fi
    # Include pattern.
    if [[ -n "${dict[include]}" ]]
    then
        x="$( \
            koopa::print "$x" \
                | koopa::grep \
                    --extended-regexp "${dict[include]}" \
        )"
        if [[ -z "$x" ]]
        then
            koopa::warn "No files left with '--include' argument."
            return 1
        fi
    fi
    koopa::print "$x"
    return 0
}

koopa::aws_s3_ls() { # {{{1
    # """
    # List an AWS S3 bucket.
    # @note Updated 2021-11-05.
    #
    # @seealso
    # - aws s3 ls help
    #
    # @examples
    # prefix='s3://r.acidgenomics.com/src/contrib/'
    #
    # Files and directories (default).
    # koopa::aws_s3_ls "$prefix"
    #
    # # Files only:
    # koopa::aws_s3_ls --type='f' "$prefix"
    #
    # # Directories only:
    # koopa::aws_s3_ls --type='d' "$prefix"
    # """
    local app dict flags pos x
    declare -A app=(
        [awk]="$(koopa::locate_awk)"
        [aws]="$(koopa::locate_aws)"
        [sed]="$(koopa::locate_sed)"
    )
    declare -A dict=(
        [prefim]='s3://'
        [profile]="${AWS_PROFILE:-}"
        [recursive]=0
        [type]=''
    )
    [[ -z "${dict[profile]}" ]] && dict[profile]='default'
    flags=()
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
                flags+=('--recursive')
                shift 1
                ;;
            # Other ------------------------------------------------------------
            '-'*)
                koopa::invalid_arg "$1"
                ;;
            *)
                pos+=("$1")
                shift 1
                ;;
        esac
    done
    [[ "${#pos[@]}" -gt 0 ]] && set -- "${pos[@]}"
    # Don't allow '--type' argument when '--recursive' flag is set.
    if [[ "${dict[recursive]}" -eq 1 ]] && \
        [[ -n "${dict[type]}" ]]
    then
        koopa::stop "'--type' argument not supported for '--recursive' mode."
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
            koopa::stop "Unsupported type: '${dict[type]}'."
            ;;
    esac
    if [[ "$#" -gt 0 ]]
    then
        dict[prefix]="${1:?}"
    fi
    if [[ "${dict[prefix]}" != 's3://' ]]
    then
        dict[prefix]="$(koopa::strip_trailing_slash "${dict[prefix]}")"
        dict[prefix]="${dict[prefix]}/"
    fi
    # Automatically add 's3://' if missing.
    if ! koopa::str_detect_regex "${dict[prefix]}" '^s3://'
    then
        dict[prefix]="s3://${dict[prefix]}"
    fi
    x="$( \
        "${app[aws]}" --profile="${dict[profile]}" \
            s3 ls "${flags[@]}" "${dict[prefix]}" \
    )"
    if [[ "$#" -eq 0 ]]
    then
        koopa::print "$x"
    fi
    # Recursive mode. Note that in this mode, 'aws s3 ls' returns the full path
    # after the bucket name.
    if [[ "${dict[recursive]}" -eq 1 ]]
    then
        dict[bucket_prefix]="$( \
            koopa::print "${dict[prefix]}" \
                | koopa::grep \
                    --extended-regexp \
                    --only-matching \
                    '^s3://[^/]+' \
        )"
        files="$( \
            koopa::print "$x" \
                | koopa::grep \
                    --extended-regexp \
                    '^[0-9]{4}-[0-9]{2}-[0-9]{2}' \
                || true \
        )"
        [[ -n "$files" ]] || return 0
        files="$( \
            # shellcheck disable=SC2016
            koopa::print "$files" \
                | "${app[awk]}" '{print $4}' \
                | "${app[awk]}" 'NF' \
                | "${app[sed]}" "s|^|${dict[bucket_prefix]}/|g" \
        )"
        koopa::print "$files"
        return 0
    fi
    # Directories.
    if [[ "${dict[dirs]}" -eq 1 ]]
    then
        dirs="$( \
            koopa::print "$x" \
                | koopa::grep \
                    --extended-regexp \
                    --only-matching \
                    '^\s+PRE\s.+/$' \
                || true \
        )"
        if [[ -n "$dirs" ]]
        then
            dirs="$( \
                koopa::print "$dirs" \
                    | "${app[sed]}" 's|^ \+PRE ||g' \
                    | "${app[awk]}" 'NF' \
                    | "${app[sed]}" "s|^|${dict[prefix]}|g" \
            )"
            koopa::print "$dirs"
        fi
    fi
    # Files.
    if [[ "${dict[files]}" -eq 1 ]]
    then
        files="$( \
            koopa::print "$x" \
                | koopa::grep \
                    --extended-regexp \
                    '^[0-9]{4}-[0-9]{2}-[0-9]{2}' \
                || true \
        )"
        if [[ -n "$files" ]]
        then
            # shellcheck disable=SC2016
            files="$( \
                koopa::print "$files" \
                    | "${app[awk]}" '{print $4}' \
                    | "${app[awk]}" 'NF' \
                    | "${app[sed]}" "s|^|${dict[prefix]}|g" \
            )"
            koopa::print "$files"
        fi
    fi
    return 0
}

koopa::aws_s3_mv_to_parent() { # {{{1
    # """
    # Move objects in an S3 bucket directory to parent directory.
    #
    # @note Updated 2021-11-05.
    #
    # @details
    # Empty directory will be removed automatically, since S3 uses object
    # storage.
    # """
    local app dict pos
    local bn dn1 dn2 file files prefix profile target x
    koopa::assert_has_args "$#"
    declare -A app=(
        [aws]="$(koopa::locate_aws)"
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
                koopa::invalid_arg "$1"
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
        koopa::assert_has_args_eq "$#" 1
        dict[prefix]="${1:?}"
    fi
    koopa::assert_is_set \
        '--profile or AWS_PROFILE' "${dict[profile]:-}"
        '--prefix' "${dict[prefix]:-}"
    x="$( \
        koopa::aws_s3_ls \
            --profile="${dict[profile]}" \
            "${dict[prefix]}" \
    )"
    if [[ -z "$x" ]]
    then
        koopa::warn "Failed to list any files in '${dict[prefix]}'."
        return 1
    fi
    readarray -t files <<< "$x"
    for file in "${files[@]}"
    do
        bn="$(koopa::basename "$file")"
        dn1="$(koopa::dirname "$file")"
        dn2="$(koopa::dirname "$dn1")"
        target="${dn2}/${bn}"
        "${app[aws]}" --profile="${dict[profile]}" \
            s3 mv "$file" "$target"
    done
    return 0
}

# FIXME Consider ignoring all files managed under git by default.
# These files are returned by 'git ls-files'.
# See also:
# - https://superuser.com/questions/429693

koopa::aws_s3_sync() { # {{{1
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
    # - *.Rproj directories.
    # - *.swp files (from vim).
    # """
    local aws dict exclude_args exclude_patterns pattern pos sync_args
    koopa::assert_has_args "$#"
    declare -A app=(
        [aws]="$(koopa::locate_aws)"
    )
    declare -A dict=(
        [profile]="${AWS_PROFILE:-}"
    )
    [[ -z "${dict[profile]}" ]] && dict[profile]='default'
    # Include common file system and Git cruft that we don't want on S3.
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
                koopa::invalid_arg "$1"
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
        koopa::assert_has_args_eq "$#" 2
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
