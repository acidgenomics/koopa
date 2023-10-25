#!/usr/bin/env bash

koopa_cli() {
    # """
    # Main koopa CLI function, corresponding to 'koopa' binary.
    # @note Updated 2023-10-25.
    #
    # Need to update corresponding Bash completion file in
    # 'etc/completion/koopa.sh'.
    # """
    local -A bool dict
    koopa_assert_has_args "$#"
    bool['nested']=0
    case "${1:?}" in
        '--version' | \
        '-V' | \
        'version')
            dict['key']='koopa-version'
            shift 1
            ;;
        'header')
            dict['key']="$1"
            shift 1
            ;;
        # Nested CLI runners ---------------------------------------------------
        'app' | \
        'configure' | \
        'install' | \
        'reinstall' | \
        'system' | \
        'uninstall' | \
        'update')
            bool['nested']=1
            dict['key']="cli-${1}"
            shift 1
            ;;
        *)
            koopa_cli_invalid_arg "$@"
            ;;
    esac
    # Evaluate nested CLI runner function and reset positional arguments.
    if [[ "${bool['nested']}"  -eq 1 ]]
    then
        dict['fun']="koopa_${dict['key']//-/_}"
        koopa_assert_is_function "${dict['fun']}"
    else
        dict['fun']="$(koopa_which_function "${dict['key']}" || true)"
    fi
    if ! koopa_is_function "${dict['fun']}"
    then
        koopa_stop 'Unsupported command.'
    fi
    "${dict['fun']}" "$@"
    return 0
}
