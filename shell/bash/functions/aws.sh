#!/usr/bin/env bash

# Better programmatic access:
# > aws s3api list-buckets --output json
# > aws s3api list-objects \
# >     --output json \
# >     --bucket tests.acidgenomics.com

_koopa_aws_cp_regex() {  # {{{1
    # """
    # Copy a local file or S3 object to another location locally or in S3 using
    # regular expression pattern matching.
    #
    # @note Updated 2020-06-29.
    #
    # @seealso
    # - aws s3 cp help
    # """
    [[ "$#" -gt 0 ]] || return 1
    _koopa_assert_is_installed aws
    local pattern source_prefix target_prefix
    pattern="${1:?}"
    source_prefix="${2:?}"
    target_prefix="${3:?}"
    aws s3 cp \
        --exclude="*" \
        --follow-symlinks \
        --include="$pattern" \
        --recursive \
        "$source_prefix" \
        "$target_prefix"
    return 0
}

_koopa_aws_s3_find() {  # {{{1
    # """
    # Find files in an AWS S3 bucket.
    #
    # @note Updated 2020-06-29.
    #
    # @seealso
    # - https://docs.aws.amazon.com/cli/latest/reference/s3/
    #
    # @examples
    # aws-s3-find \
    #     --include="*.bw$" \
    #     --exclude="antisense" \
    #     s3://bioinfo/igv/
    # """
    [[ "$#" -gt 0 ]] || return 1
    _koopa_assert_is_installed aws
    local exclude include pos x
    exclude=
    include=
    pos=()
    while (("$#"))
    do
        case "$1" in
            --exclude=*)
                exclude="${1#*=}"
                shift 1
                ;;
            --exclude)
                exclude="$2"
                shift 2
                ;;
            --include=*)
                include="${1#*=}"
                shift 1
                ;;
            --include)
                include="$2"
                shift 2
                ;;
            --)
                shift 1
                break
                ;;
            --*|-*)
                _koopa_invalid_arg "$1"
                ;;
            *)
                pos+=("$1")
                shift 1
                ;;
        esac
    done
    [[ "${#pos[@]}" -gt 0 ]] && set -- "${pos[@]}"
    x="$(_koopa_aws_s3_ls --recursive "$@")"
    [[ -n "$x" ]] || return 1
    # Exclude pattern.
    if [[ -n "${exclude:-}" ]]
    then
        x="$(_koopa_print "$x" | grep -Ev "$exclude")"
        [[ -n "$x" ]] || return 1
    fi
    # Include pattern.
    if [[ -n "${include:-}" ]]
    then
        x="$(_koopa_print "$x" | grep -E "$include")"
        [[ -n "$x" ]] || return 1
    fi
    _koopa_print "$x"
    return 0
}

_koopa_aws_s3_ls() {  # {{{1
    # """
    # List an AWS S3 bucket.
    # @note Updated 2020-06-29.
    #
    # @seealso
    # - aws s3 ls help
    #
    # @examples
    # _koopa_aws_s3_ls s3://cpi-bioinfo01/
    # _koopa_aws_s3_ls cpi-bioinfo01/
    # # Directories only:
    # aws-s3-ls --type=f s3://cpi-bioinfo01/datasets/
    # """
    _koopa_assert_is_installed aws
    if [[ "$#" -eq 0 ]]
    then
        aws s3 ls
        exit 0
    fi
    local bucket_prefix dirs files flags pos prefix recursive type x
    flags=()
    recursive=0
    type=
    pos=()
    while (("$#"))
    do
        case "$1" in
            --recursive)
                recursive=1
                flags+=("--recursive")
                shift 1
                ;;
            --type=*)
                type="${1#*=}"
                shift 1
                ;;
            --type)
                type="$2"
                shift 2
                ;;
            --)
                shift 1
                break
                ;;
            --*|-*)
                _koopa_invalid_arg "$1"
                ;;
            *)
                pos+=("$1")
                shift 1
                ;;
        esac
    done
    [[ "${#pos[@]}" -gt 0 ]] && set -- "${pos[@]}"
    # Don't allow '--type' argument when '--recursive' flag is set.
    if [[ "$recursive" -eq 1 ]] && [[ -n "$type" ]]
    then
        _koopa_stop "'--type' argument isn't supported for '--recursive' mode."
    fi
    case "${type:-}" in
        d)
            dirs=1
            files=0
            ;;
        f)
            dirs=0
            files=1
            ;;
        *)
            dirs=1
            files=1
            ;;
    esac
    prefix="${1:?}"
    prefix="$(_koopa_strip_trailing_slash "$prefix")"
    prefix="${prefix}/"
    # Automatically add 's3://' if missing.
    if ! _koopa_str_match_regex "$prefix" "^s3://"
    then
        prefix="s3://${prefix}"
    fi
    x="$(aws s3 ls "${flags[@]}" "$prefix")"
    # Recursive mode.
    # Note that in '--recursive' mode, 'aws s3 ls' returns the full path after
    # the bucket name.
    if [[ "$recursive" -eq 1 ]]
    then
        bucket_prefix="$(_koopa_print "$prefix" | grep -Eo '^s3://[^/]+')"
        files="$( \
            _koopa_print "$x" \
            | grep -E '^[0-9]{4}-[0-9]{2}-[0-9]{2}' \
            || true \
        )"
        [[ -n "$files" ]] || return 0
        files="$( \
            _koopa_print "$files" \
                | grep -Eo '  [0-9]+ .+$' \
                | sed 's/^  [0-9]* //g' \
                | sed "s|^|${bucket_prefix}/|g" \
        )"
        _koopa_print "$files"
        return 0
    fi
    # Directories.
    if [[ "$dirs" -eq 1 ]]
    then
        dirs="$(_koopa_print "$x" | grep -Eo '  PRE .+$' || true)"
        if [[ -n "$dirs" ]]
        then
            dirs="$( \
                _koopa_print "$dirs" \
                    | sed 's/^  PRE //g' \
                    | sed "s|^|${prefix}|g" \
            )"
            _koopa_print "$dirs"
        fi
    fi
    # Files.
    if [[ "$files" -eq 1 ]]
    then
        files="$( \
            _koopa_print "$x" \
            | grep -E '^[0-9]{4}-[0-9]{2}-[0-9]{2}' \
            || true \
        )"
        if [[ -n "$files" ]]
        then
            files="$( \
                _koopa_print "$files" \
                    | grep -Eo '  [0-9]+ .+$' \
                    | sed 's/^  [0-9]* //g' \
                    | sed "s|^|${prefix}|g" \
            )"
            _koopa_print "$files"
        fi
    fi
    return 0
}

_koopa_aws_s3_mv_to_parent() {  # {{{1
    # """
    # Move objects in an S3 bucket to parent directory.
    #
    # @note Updated 2020-06-29.
    #
    # @details
    # Empty directory will be removed automatically, since S3 uses object
    # storage.
    # """
    [[ "$#" -gt 0 ]] || return 1
    _koopa_assert_is_installed aws
    local bn dn1 dn2 file files prefix target x
    prefix="${1:?}"
    x="$(aws-s3-ls "$prefix")"
    [[ -n "$x" ]] || return 0
    readarray -t files <<< "$x"
    for file in "${files[@]}"
    do
        bn="$(basename "$file")"
        dn1="$(dirname "$file")"
        dn2="$(dirname "$dn1")"
        target="${dn2}/${bn}"
        aws s3 mv "$file" "$target"
    done
    return 0
}

_koopa_aws_s3_sync() {  # {{{1
    # """
    # Sync an S3 bucket, but ignore some files automatically.
    #
    # @note Updated 2020-06-29.
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
    # Nuclear dotfile option: --exclude=".*"
    # Otherwise, can manually ignore '.git', '.gitignore', etc.
    #
    # Currently ignores:
    # - Invisible dot files, prefixed with '.'.
    # - Temporary files.
    # - *.Rproj directories.
    # - *.swp files (from vim).
    # """
    [[ "$#" -gt 0 ]] || return 1
    _koopa_assert_is_installed aws
    aws s3 sync \
        --exclude="*.Rproj/*" \
        --exclude="*.swp" \
        --exclude="*.tmp" \
        --exclude=".*" \
        --exclude=".DS_Store" \
        --exclude=".Rproj.user/*" \
        --exclude="._*" \
        --exclude=".git/*" \
        "$@"
}
