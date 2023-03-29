#!/usr/bin/env bash

koopa_cli_reinstall() {
    # """
    # Parse user input to 'koopa reinstall'
    # @note Updated 2023-03-29.
    # """
    local dict pos
    koopa_assert_has_args "$#"
    declare -A dict
    dict['mode']='default'
    pos=()
    while (("$#"))
    do
        case "$1" in
            '--all')
                koopa_invalid_arg "$1"
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
        'all-revdeps')
            koopa_reinstall_all_revdeps "$@"
            ;;
        'default')
            koopa_cli_install --reinstall "$@"
            ;;
        'only-revdeps')
            koopa_reinstall_only_revdeps "$@"
            ;;
    esac
    return 0
}
