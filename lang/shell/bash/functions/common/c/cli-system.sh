#!/usr/bin/env bash

koopa_cli_system() {
    # """
    # Parse user input to 'koopa system'.
    # @note Updated 2022-05-20.
    # """
    local key
    key=''
    # Platform independent.
    case "${1:-}" in
        '--help' | \
        '-h')
            koopa_help "$(koopa_man_prefix)/man1/system.1"
            ;;
        'check')
            key='check-system'
            shift 1
            ;;
        'info')
            key='system-info'
            shift 1
            ;;
        'list')
            case "${2:-}" in
                'app-versions' | \
                'dotfiles' | \
                'launch-agents' | \
                'path-priority' | \
                'programs')
                    key="${1:?}-${2:?}"
                    shift 2
                    ;;
            esac
            ;;
        'log')
            key='view-latest-tmp-log-file'
            shift 1
            ;;
        'prefix')
            case "${2:-}" in
                '')
                    key='koopa-prefix'
                    shift 1
                    ;;
                'koopa')
                    key='koopa-prefix'
                    shift 2
                    ;;
                *)
                    key="${2}-prefix"
                    shift 2
                    ;;
            esac
            ;;
        'version')
            key='get-version'
            shift 1
            ;;
        'which')
            key='which-realpath'
            shift 1
            ;;
        'brew-dump-brewfile' | \
        'brew-outdated' | \
        'cache-functions' | \
        'disable-passwordless-sudo' | \
        'enable-passwordless-sudo' | \
        'find-non-symlinked-make-files' | \
        'fix-zsh-permissions' | \
        'host-id' | \
        'os-string' | \
        'reload-shell' | \
        'roff' | \
        'push-app-build' | \
        'set-permissions' | \
        'switch-to-develop' | \
        'test' | \
        'variable' | \
        'variables')
            # FIXME This isn't passing arguments for 'push-app-build' correctly.
            key="${1:?}"
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
    if [[ -z "$key" ]]
    then
        if koopa_is_linux
        then
            case "${1:-}" in
                'delete-cache' | \
                'fix-sudo-setrlimit-error')
                    key="${1:?}"
                    shift 1
                    ;;
            esac
        elif koopa_is_macos
        then
            case "${1:-}" in
                'spotlight')
                    key='spotlight-find'
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
                    key="${1:?}"
                    shift 1
                    ;;
            esac
        fi
    fi
    [[ -z "$key" ]] && koopa_cli_invalid_arg "$@"
    koopa_print "$key" "$@"
    return 0
}
