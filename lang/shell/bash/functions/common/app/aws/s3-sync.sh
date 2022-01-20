#!/usr/bin/env bash


# Better programmatic access example:
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
#
# FIXME Consider naming this option '--ignore-git'.
# This should only apply when source is local, and target is 's3://...'.

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
