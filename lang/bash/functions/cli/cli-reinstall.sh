#!/usr/bin/env bash

_koopa_cli_reinstall() {
    # """
    # Parse user input to 'koopa reinstall'
    # @note Updated 2023-04-05.
    # """
    local -A dict
    local -a pos
    _koopa_assert_has_args "$#"
    dict['mode']='default'
    pos=()
    while (("$#"))
    do
        case "$1" in
            '--all')
                _koopa_invalid_arg "$1"
                ;;
            '--all-revdeps')
                dict['mode']='all-revdeps'
                shift 1
                ;;
            '--only-revdeps')
                dict['mode']='only-revdeps'
                shift 1
                ;;
            *)
                pos+=("$1")
                shift 1
                ;;
        esac
    done
    [[ "${#pos[@]}" -gt 0 ]] && set -- "${pos[@]}"
    case "${dict['mode']}" in
        'all-revdeps' | \
        'all-reverse-dependencies')
            _koopa_reinstall_all_revdeps "$@"
            ;;
        'default')
            _koopa_cli_install --reinstall "$@"
            local -a stale_revdeps
            local stale_str
            stale_str="$(_koopa_stale_revdeps "$@")" || true
            if [[ -n "$stale_str" ]]
            then
                readarray -t stale_revdeps <<< "$stale_str"
                if _koopa_is_array_non_empty "${stale_revdeps[@]:-}"
                then
                    _koopa_dl \
                        'stale reverse dependencies' \
                        "$(_koopa_to_string "${stale_revdeps[@]}")"
                    _koopa_cli_install --reinstall "${stale_revdeps[@]}"
                fi
            fi
            ;;
        'only-revdeps' | \
        'only-reverse-dependencies')
            _koopa_reinstall_only_revdeps "$@"
            ;;
    esac
    return 0
}
