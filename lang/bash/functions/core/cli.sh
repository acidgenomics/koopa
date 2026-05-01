#!/usr/bin/env bash

_koopa_cli() {
    # """
    # Main koopa CLI function, corresponding to 'koopa' binary.
    # @note Updated 2024-07-12.
    #
    # Need to update corresponding Bash completion file in
    # 'etc/completion/koopa.sh'.
    #
    # @seealso
    # - How to remove last positional argument:
    #   https://stackoverflow.com/a/26163980/3911732
    # """
    local -A bool dict
    _koopa_assert_has_args "$#"
    bool['nested']=0
    case "${!#}" in
        '--help' | \
        '-h')
            set -- "${@:1:$(($#-1))}"
            dict['key']="$(_koopa_paste --sep='/' "$@")"
            dict['man_file']="$(_koopa_man_prefix)/man1/koopa/${dict['key']}.1"
            _koopa_assert_is_file "${dict['man_file']}"
            _koopa_help "${dict['man_file']}"
            ;;
    esac
    case "${1:?}" in
        '--version' | \
        '-V' | \
        'version')
            dict['key']='koopa-version'
            shift 1
            ;;
        'header' | \
        'install-all-apps' | \
        'install-default-apps')
            dict['key']="$1"
            shift 1
            ;;
        # Nested CLI runners ---------------------------------------------------
        'app' | \
        'configure' | \
        'develop' | \
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
            _koopa_cli_invalid_arg "$@"
            ;;
    esac
    # Evaluate nested CLI runner function and reset positional arguments.
    if [[ "${bool['nested']}"  -eq 1 ]]
    then
        dict['fun']="_koopa_${dict['key']//-/_}"
        _koopa_assert_is_function "${dict['fun']}"
    else
        dict['fun']="$(_koopa_which_function "${dict['key']}" || true)"
    fi
    if ! _koopa_is_function "${dict['fun']}"
    then
        _koopa_stop 'Unsupported command.'
    fi
    "${dict['fun']}" "$@"
    return 0
}
