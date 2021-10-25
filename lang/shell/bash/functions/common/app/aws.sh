#!/usr/bin/env bash

# Better programmatic access:
# > aws s3api list-buckets --output json
# > aws s3api list-objects \
# >     --output json \
# >     --bucket koopa.acidgenomics.com

koopa::aws_batch_fetch_and_run() { # {{{1
    # """
    # Fetch and run a script on AWS Batch.
    # @note Updated 2021-09-21.
    #
    # S3 bucket paths and remote URLs are supported.
    #
    # @seealso
    # - https://github.com/FredHutch/url-fetch-and-run
    # - https://github.com/awslabs/aws-batch-helpers
    # """
    local aws file profile url
    koopa::assert_has_no_args "$#"
    koopa::assert_is_set 'BATCH_FILE_URL'
    url="${BATCH_FILE_URL:?}"
    file="$(koopa::tmp_file)"
    case "$url" in
        'ftp'* | \
        'http'*)
            koopa::download "$url" "$file"
            ;;
        's3'*)
            aws="$(koopa::locate_aws)"
            profile="${AWS_PROFILE:-default}"
            "$aws" --profile="$profile" \
                s3 cp "$url" "$file"
            ;;
        *)
            koopa::stop "Unsupported URL: '${url}'."
            ;;
    esac
    koopa::chmod 'u+x' "$file"
    "$file"
    return 0
}

koopa::aws_batch_list_jobs() { # {{{1
    # """
    # List AWS Batch jobs.
    # @note Updated 2021-09-21.
    # """
    local aws job_queue job_queue_array profile status status_array
    aws="$(koopa::locate_aws)"
    profile="${AWS_PROFILE:-default}"
    while (("$#"))
    do
        case "$1" in
            # Key-value pairs --------------------------------------------------
            '--profile='*)
                profile="${1#*=}"
                shift 1
                ;;
            '--profile')
                profile="${2:?}"
                shift 2
                ;;
            # Other ------------------------------------------------------------
            *)
                koopa::invalid_arg "$1"
                ;;
        esac
    done
    koopa::assert_has_no_args "$#"
    koopa::assert_is_set \
        'AWS_BATCH_ACCOUNT_ID' \
        'AWS_BATCH_QUEUE' \
        'AWS_BATCH_REGION'
    koopa::h1 "Checking AWS Batch job status for '${profile}' profile."
    job_queue_array=(
        'arn'
        'aws'
        'batch'
        "${AWS_BATCH_REGION:?}"
        "${AWS_BATCH_ACCOUNT_ID:?}"
        "job-queue/${AWS_BATCH_QUEUE:?}"
    )
    job_queue="$(koopa::paste0 ':' "${job_queue_array[@]}")"
    status_array=(
        'SUBMITTED'
        'PENDING'
        'RUNNABLE'
        'STARTING'
        'RUNNING'
        'SUCCEEDED'
        'FAILED'
    )
    for status in "${status_array[@]}"
    do
        koopa::h2 "$status"
        "$aws" --profile="$profile" \
            batch list-jobs \
                --job-queue "$job_queue" \
                --job-status "$status"
    done
    return 0
}

koopa::aws_cp_regex() { # {{{1
    # """
    # Copy a local file or S3 object to another location locally or in S3 using
    # regular expression pattern matching.
    #
    # @note Updated 2021-09-21.
    #
    # @seealso
    # - aws s3 cp help
    # """
    local aws pattern pos profile source_prefix target_prefix
    koopa::assert_has_args "$#"
    aws="$(koopa::locate_aws)"
    profile="${AWS_PROFILE:-default}"
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
            '-'*)
                koopa::invalid_arg "$1"
                ;;
            *)
                pos+=("$1")
                shift 1
                ;;
        esac
    done
    # Providing legacy support for positional arguments. This may be removed
    # in a future update in favor of requiring named arguments.
    [[ "${#pos[@]}" -gt 0 ]] && set -- "${pos[@]}"
    if [[ "$#" -gt 0 ]]
    then
        koopa::assert_has_args_eq "$#" 3
        pattern="${1:?}"
        source_prefix="${2:?}"
        target_prefix="${3:?}"
    fi
    "$aws" --profile="$profile" \
        s3 cp \
            --exclude='*' \
            --follow-symlinks \
            --include="$pattern" \
            --recursive \
            "$source_prefix" \
            "$target_prefix"
    return 0
}

koopa::aws_s3_find() { # {{{1
    # """
    # Find files in an AWS S3 bucket.
    #
    # @note Updated 2021-09-21.
    #
    # @seealso
    # - https://docs.aws.amazon.com/cli/latest/reference/s3/
    #
    # @examples
    # koopa::aws_s3_find \
    #     --include="*.bw$" \
    #     --exclude="antisense" \
    #     s3://bioinfo/igv/
    # """
    local exclude include pos profile x
    koopa::assert_has_args "$#"
    profile="${AWS_PROFILE:-default}"
    exclude=''
    include=''
    pos=()
    while (("$#"))
    do
        case "$1" in
            # Key-value pairs --------------------------------------------------
            '--exclude='*)
                exclude="${1#*=}"
                shift 1
                ;;
            '--exclude')
                exclude="${2:?}"
                shift 2
                ;;
            '--include='*)
                include="${1#*=}"
                shift 1
                ;;
            '--include')
                include="${2:?}"
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
        --profile="$profile" \
        --recursive \
        "$@" \
    )"
    [[ -n "$x" ]] || return 1
    # Exclude pattern.
    if [[ -n "${exclude:-}" ]]
    then
        x="$( \
            koopa::print "$x" \
                | koopa::grep \
                    --extended-regexp \
                    --invert-match \
                    "$exclude" \
        )"
        [[ -n "$x" ]] || return 1
    fi
    # Include pattern.
    if [[ -n "${include:-}" ]]
    then
        x="$( \
            koopa::print "$x" \
                | koopa::grep --extended-regexp "$include" \
        )"
        [[ -n "$x" ]] || return 1
    fi
    koopa::print "$x"
    return 0
}

koopa::aws_s3_ls() { # {{{1
    # """
    # List an AWS S3 bucket.
    # @note Updated 2021-10-25.
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
        [profile]="${AWS_PROFILE:-default}"
        [recursive]=0
        [type]=''
    )
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
    if ! koopa::str_match_regex "${dict[prefix]}" '^s3://'
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
    # @note Updated 2021-09-21.
    #
    # @details
    # Empty directory will be removed automatically, since S3 uses object
    # storage.
    # """
    local aws bn dn1 dn2 file files pos prefix profile target x
    koopa::assert_has_args "$#"
    aws="$(koopa::locate_aws)"
    profile="${AWS_PROFILE:-default}"
    pos=()
    while (("$#"))
    do
        case "$1" in
            # Key-value pairs --------------------------------------------------
            '--prefix='*)
                prefix="${1#*=}"
                shift 1
                ;;
            '--prefix')
                prefix="${2:?}"
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
        prefix="${1:?}"
    fi
    x="$( \
        koopa::aws_s3_ls \
            --profile="$profile" \
            "$prefix" \
    )"
    [[ -n "$x" ]] || return 0
    readarray -t files <<< "$x"
    for file in "${files[@]}"
    do
        bn="$(koopa::basename "$file")"
        dn1="$(koopa::dirname "$file")"
        dn2="$(koopa::dirname "$dn1")"
        target="${dn2}/${bn}"
        "$aws" --profile="$profile" \
            s3 mv "$file" "$target"
    done
    return 0
}

# FIXME subdirectory exclusion still isn't working perfectly.
koopa::aws_s3_sync() { # {{{1
    # """
    # Sync an S3 bucket, but ignore some files automatically.
    # @note Updated 2021-10-05.
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
    aws="$(koopa::locate_aws)"
    declare -A dict=(
        [profile]="${AWS_PROFILE:-default}"
    )
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
    "$aws" --profile="${dict[profile]}" \
        s3 sync \
            "${exclude_args[@]}" \
            "${sync_args[@]}"
    return 0
}
