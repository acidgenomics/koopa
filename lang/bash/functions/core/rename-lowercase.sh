#!/usr/bin/env bash

_koopa_rename_lowercase() {
    # """
    # Rename files to lowercase.
    # @note Updated 2023-04-05.
    #
    # @usage _koopa_rename_lowercase FILE...
    # """
    local -A app dict
    local -a pos
    _koopa_assert_has_args "$#"
    app['rename']="$(_koopa_locate_rename)"
    app['xargs']="$(_koopa_locate_xargs)"
    _koopa_assert_is_executable "${app[@]}"
    dict['pattern']='y/A-Z/a-z/'
    dict['recursive']=0
    pos=()
    while (("$#"))
    do
        case "$1" in
            '--recursive')
                dict['recursive']=1
                shift 1
                ;;
            '-'*)
                _koopa_invalid_arg "$1"
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
        _koopa_assert_has_args_le "$#" 1
        dict['prefix']="${1:-.}"
        _koopa_assert_is_dir "${dict['prefix']}"
        # Rename files.
        _koopa_find \
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
        _koopa_find \
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
