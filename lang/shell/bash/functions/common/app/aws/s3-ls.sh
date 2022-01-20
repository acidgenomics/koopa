#!/usr/bin/env bash

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
