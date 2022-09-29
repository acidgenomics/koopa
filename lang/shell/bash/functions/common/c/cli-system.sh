#!/usr/bin/env bash

koopa_cli_system() {
    # """
    # Parse user input to 'koopa system'.
    # @note Updated 2022-08-24.
    # """
    local dict
    declare -A dict=(
        ['key']=''
    )
    # Platform independent.
    case "${1:-}" in
        'check')
            dict['key']='check-system'
            shift 1
            ;;
        'info')
            dict['key']='system-info'
            shift 1
            ;;
        'list')
            case "${2:-}" in
                'app-versions' | \
                'dotfiles' | \
                'launch-agents' | \
                'path-priority' | \
                'programs')
                    dict['key']="${1:?}-${2:?}"
                    shift 2
                    ;;
            esac
            ;;
        'log')
            dict['key']='view-latest-tmp-log-file'
            shift 1
            ;;
        'prefix')
            case "${2:-}" in
                '')
                    dict['key']='koopa-prefix'
                    shift 1
                    ;;
                'koopa')
                    dict['key']='koopa-prefix'
                    shift 2
                    ;;
                *)
                    dict['key']="${2}-prefix"
                    shift 2
                    ;;
            esac
            ;;
        'version')
            dict['key']='get-version'
            shift 1
            ;;
        'which')
            dict['key']='which-realpath'
            shift 1
            ;;
        'build-all-apps' | \
        'cache-functions' | \
        'disable-passwordless-sudo' | \
        'enable-passwordless-sudo' | \
        'find-non-symlinked-make-files' | \
        'fix-zsh-permissions' | \
        'host-id' | \
        'os-string' | \
        'push-app-build' | \
        'reload-shell' | \
        'roff' | \
        'set-permissions' | \
        'switch-to-develop' | \
        'test' | \
        'variable' | \
        'variables')
            dict['key']="${1:?}"
            shift 1
            ;;
        # Defunct --------------------------------------------------------------
        'conda-create-env')
            koopa_defunct 'koopa app conda create-env'
            ;;
        'conda-remove-env')
            koopa_defunct 'koopa app conda remove-env'
            ;;
    esac
    # Platform specific.
    if [[ -z "${dict['key']}" ]]
    then
        if koopa_is_linux
        then
            case "${1:-}" in
                'delete-cache' | \
                'fix-sudo-setrlimit-error')
                    dict['key']="${1:?}"
                    shift 1
                    ;;
            esac
        elif koopa_is_macos
        then
            case "${1:-}" in
                'spotlight')
                    dict['key']='spotlight-find'
                    shift 1
                    ;;
                'clean-launch-services' | \
                'create-dmg' | \
                'disable-touch-id-sudo' | \
                'enable-touch-id-sudo' | \
                'flush-dns' | \
                'force-eject' | \
                'ifactive' | \
                'list-launch-agents' | \
                'reload-autofs')
                    dict['key']="${1:?}"
                    shift 1
                    ;;
            esac
        fi
    fi
    [[ -z "${dict['key']}" ]] && koopa_cli_invalid_arg "$@"
    dict['fun']="$(koopa_which_function "${dict['key']}" || true)"
    if ! koopa_is_function "${dict['fun']}"
    then
        koopa_stop 'Unsupported command.'
    fi
    "${dict['fun']}" "$@"
    return 0
}
