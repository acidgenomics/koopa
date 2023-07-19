#!/usr/bin/env bash

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
# FIXME Don't allow positional arguments here.
# FIXME Exclude uses glob matching here, whereas our find pattern uses regex...
# FIXME Improve this to automatically exclude files under git!
# FIXME Support using '--dry-run' instead of '--dryrun'.

koopa_aws_s3_sync() {
    # """
    # Sync an S3 bucket, but ignore some files automatically.
    # @note Updated 2023-07-18.
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
    local -A app dict
    local -a exclude_args exclude_patterns pos sync_args
    local pattern
    koopa_assert_has_args "$#"
    app['aws']="$(koopa_locate_aws)"
    koopa_assert_is_executable "${app[@]}"
    dict['profile']="${AWS_PROFILE:-default}"
    # Include common file system and Git cruft that we don't want on S3.
    # FIXME Only set this if the user doesn't pass in exclude?
    # FIXME Can we use '**' glob patterns here? Is that the key?
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
                dict['profile']="${1#*=}"
                shift 1
                ;;
            '--profile')
                dict['profile']="${2:?}"
                shift 2
                ;;
            '--source-prefix='*)
                dict['source_prefix']="${1#*=}"
                shift 1
                ;;
            '--source-prefix')
                dict['source_prefix']="${2:?}"
                shift 2
                ;;
            '--target-prefix='*)
                dict['target_prefix']="${1#*=}"
                shift 1
                ;;
            '--target-prefix')
                dict['target_prefix']="${2:?}"
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
        koopa_assert_has_no_flags "$@"
        sync_args+=("$@")
    else
        sync_args+=(
            "${dict['source_prefix']}"
            "${dict['target_prefix']}"
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
    "${app['aws']}" s3 sync \
        --profile "${dict['profile']}" \
        "${exclude_args[@]}" \
        "${sync_args[@]}"
    return 0
}
