#!/usr/bin/env bash

koopa_cli() {
    # """
    # Main koopa CLI function, corresponding to 'koopa' binary.
    # @note Updated 2022-07-14.
    #
    # Need to update corresponding Bash completion file in
    # 'etc/completion/koopa.sh'.
    # """
    local dict
    koopa_assert_has_args "$#"
    declare -A dict=(
        [nested]=0
    )
    case "${1:?}" in
        '--help' | \
        '-h')
            dict[manfile]="$(koopa_man_prefix)/man1/koopa.1"
            koopa_help "${dict['manfile']}"
            return 0
            ;;
        '--version' | \
        '-V' | \
        'version')
            dict[key]='koopa-version'
            shift 1
            ;;
        'header')
            dict[key]="$1"
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
            dict[nested]=1
            dict[key]="cli-${1}"
            shift 1
            ;;
        *)
            koopa_cli_invalid_arg "$@"
            ;;
    esac
    # Evaluate nested CLI runner function and reset positional arguments.
    if [[ "${dict['nested']}"  -eq 1 ]]
    then
        dict[fun]="koopa_${dict['key']//-/_}"
        koopa_assert_is_function "${dict['fun']}"
    else
        dict[fun]="$(koopa_which_function "${dict['key']}" || true)"
    fi
    if ! koopa_is_function "${dict['fun']}"
    then
        koopa_stop 'Unsupported command.'
    fi
    "${dict['fun']}" "$@"
    return 0
}
