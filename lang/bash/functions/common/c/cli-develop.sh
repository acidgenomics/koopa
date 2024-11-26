#!/usr/bin/env bash

koopa_cli_develop() {
    # """
    # Parse user input to 'koopa develop'.
    # @note Updated 2024-11-26.
    # """
    local -A dict
    dict['key']=''
    case "${1:-}" in
        'log')
            dict['key']='view-latest-tmp-log-file'
            shift 1
            ;;
        'cache-functions' | \
        'edit-app-json' | \
        'prune-app-binaries' | \
        'push-all-app-builds' | \
        'push-app-build' | \
        'roff')
            dict['key']="${1:?}"
            shift 1
            ;;
    esac
    [[ -z "${dict['key']}" ]] && koopa_cli_invalid_arg "$@"
    dict['fun']="$(koopa_which_function "${dict['key']}" || true)"
    if ! koopa_is_function "${dict['fun']}"
    then
        koopa_stop 'Unsupported command.'
    fi
    "${dict['fun']}" "$@"
    return 0
}
