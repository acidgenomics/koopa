#!/usr/bin/env bash

koopa_rename_lowercase() {
    # """
    # Rename files to lowercase.
    # @note Updated 2022-02-24.
    #
    # @usage koopa_rename_lowercase FILE...
    # """
    local app dict pos
    koopa_assert_has_args "$#"
    local -A app=(
        ['rename']="$(koopa_locate_rename)"
        ['xargs']="$(koopa_locate_xargs)"
    )
    [[ -x "${app['rename']}" ]] || exit 1
    [[ -x "${app['xargs']}" ]] || exit 1
    local -A dict=(
        ['pattern']='y/A-Z/a-z/'
        ['recursive']=0
    )
    pos=()
    while (("$#"))
    do
        case "$1" in
            '--recursive')
                dict['recursive']=1
                shift 1
                ;;
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
    if [[ "${dict['recursive']}" -eq 1 ]]
    then
        koopa_assert_has_args_le "$#" 1
        dict['prefix']="${1:-.}"
        koopa_assert_is_dir "${dict['prefix']}"
        # Rename files.
        koopa_find \
            --exclude='.*' \
            --min-depth=1 \
            --pattern='*[A-Z]*' \
            --prefix="${dict['prefix']}" \
            --print0 \
            --sort \
            --type='f' \
        | "${app['xargs']}" -0 -I {} \
            "${app['rename']}" \
                --force \
                --verbose \
                "${dict['pattern']}" \
                {}
        # Rename directories.
        koopa_find \
            --exclude='.*' \
            --min-depth=1 \
            --pattern='*[A-Z]*' \
            --prefix="${dict['prefix']}" \
            --print0 \
            --type='d' \
        | "${app['xargs']}" -0 -I {} \
            "${app['rename']}" \
                --force \
                --verbose \
                "${dict['pattern']}" \
                {}
    else
        "${app['rename']}" \
            --force \
            --verbose \
            "${dict['pattern']}" \
            "$@"
    fi
    return 0
}
