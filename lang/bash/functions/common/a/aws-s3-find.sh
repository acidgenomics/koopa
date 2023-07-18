#!/usr/bin/env bash

# FIXME Rework this to only use JSON parsing from s3api.

koopa_aws_s3_find() {
    # """
    # Find files in an AWS S3 bucket.
    #
    # @note Updated 2022-07-18.
    #
    # This uses regular expression matching against the full path for
    # '--exclude' and '--include', instead of globbing.
    #
    # @seealso
    # - https://docs.aws.amazon.com/cli/latest/reference/s3/
    #
    # @examples
    # > koopa_aws_s3_find \
    # >     --exclude='\.(css|html)$' \
    # >     --exclude='^install$' \
    # >     --prefix='s3://koopa.acidgenomics.com/' \
    # >     --profile='acidgenomics'
    # >     --recursive
    #
    # > koopa_aws_s3_find \
    # >     --include='^installers/.+$' \
    # >     --prefix='s3://koopa.acidgenomics.com/' \
    # >     --profile='acidgenomics'
    # >     --recursive
    # """
    local -A dict
    local -a exclude_arr include_arr ls_args
    local pattern str
    koopa_assert_has_args "$#"
    dict['exclude']=0
    dict['include']=0
    dict['prefix']=''
    dict['profile']="${AWS_PROFILE:-default}"
    dict['recursive']=0
    exclude_arr=()
    include_arr=()
    while (("$#"))
    do
        case "$1" in
            # Key-value pairs --------------------------------------------------
            '--exclude='*)
                dict['exclude']=1
                exclude_arr+=("${1#*=}")
                shift 1
                ;;
            '--exclude')
                dict['exclude']=1
                exclude_arr+=("${2:?}")
                shift 2
                ;;
            '--include='*)
                dict['include']=1
                include_arr+=("${1#*=}")
                shift 1
                ;;
            '--include')
                dict['include']=1
                include_arr+=("${2:?}")
                shift 2
                ;;
            '--prefix='*)
                dict['prefix']="${1#*=}"
                shift 1
                ;;
            '--prefix')
                dict['prefix']="${2:?}"
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
            # Flags ------------------------------------------------------------
            '--recursive')
                dict['recursive']=1
                shift 1
                ;;
            # Other ------------------------------------------------------------
            *)
                koopa_invalid_arg "$1"
                ;;
        esac
    done
    koopa_assert_is_set \
        '--prefix' "${dict['prefix']}" \
        '--profile or AWS_PROFILE' "${dict['profile']}"
    koopa_assert_is_matching_regex \
        --pattern='^s3://.+/$' \
        --string="${dict['prefix']}"
    ls_args=(
        '--prefix' "${dict['prefix']}"
        '--profile' "${dict['profile']}"
        '--type' 'f'
    )
    [[ "${dict['recursive']}" -eq 1 ]] && ls_args+=('--recursive')
    str="$(koopa_aws_s3_ls "${ls_args[@]}")"
    [[ -n "$str" ]] || return 1
    # Exclude pattern.
    if [[ "${dict['exclude']}" -eq 1 ]]
    then
        for pattern in "${exclude_arr[@]}"
        do
            if koopa_str_detect_regex \
                --pattern='^\^' \
                --string="$pattern"
            then
                pattern="$( \
                    koopa_sub \
                        --pattern='^\^' \
                        --replacement='' \
                        "$pattern" \
                )"
                pattern="${dict['prefix']}${pattern}"
            fi
            str="$( \
                koopa_grep \
                    --invert-match \
                    --pattern="$pattern" \
                    --regex \
                    --string="$str" \
            )"
            [[ -n "$str" ]] || return 1
        done
    fi
    # Include pattern.
    if [[ "${dict['include']}" -eq 1 ]]
    then
        for pattern in "${include_arr[@]}"
        do
            if koopa_str_detect_regex \
                --pattern='^\^' \
                --string="$pattern"
            then
                pattern="$( \
                    koopa_sub \
                        --pattern='^\^' \
                        --replacement='' \
                        "$pattern" \
                )"
                pattern="${dict['prefix']}${pattern}"
            fi
            str="$( \
                koopa_grep \
                    --pattern="$pattern" \
                    --regex \
                    --string="$str" \
            )"
            [[ -n "$str" ]] || return 1
        done
    fi
    koopa_print "$str"
    return 0
}
