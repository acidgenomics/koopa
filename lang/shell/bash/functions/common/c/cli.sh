#!/usr/bin/env bash

koopa_cli() {
    # """
    # Main koopa CLI function, corresponding to 'koopa' binary.
    # @note Updated 2022-02-15.
    #
    # Need to update corresponding Bash completion file in
    # 'etc/completion/koopa.sh'.
    # """
    local dict
    koopa_assert_has_args "$#"
    declare -A dict=(
        [nested_runner]=0
    )
    case "${1:?}" in
        '--version' | \
        '-V' | \
        'version')
            dict[key]='koopa-version'
            shift 1
            ;;
        # This is a wrapper for 'koopa install XXX --reinstall'.
        'reinstall')
            dict[key]='reinstall-app'
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
        'system' | \
        'uninstall' | \
        'update')
            dict[nested_runner]=1
            dict[key]="cli-${1}"
            shift 1
            ;;
        # Defunct args / error catching ----------------------------------------
        'app-prefix')
            koopa_defunct 'koopa system prefix app'
            ;;
        'cellar-prefix')
            koopa_defunct 'koopa system prefix app'
            ;;
        'check' | \
        'check-system')
            koopa_defunct 'koopa system check'
            ;;
        'conda-prefix')
            koopa_defunct 'koopa system prefix conda'
            ;;
        'config-prefix')
            koopa_defunct 'koopa system prefix config'
            ;;
        'delete-cache')
            koopa_defunct 'koopa system delete-cache'
            ;;
        'fix-zsh-permissions')
            koopa_defunct 'koopa system fix-zsh-permissions'
            ;;
        'get-homebrew-cask-version')
            koopa_defunct 'koopa system homebrew-cask-version'
            ;;
        'get-macos-app-version')
            koopa_defunct 'koopa system macos-app-version'
            ;;
        'get-version')
            koopa_defunct 'koopa system version'
            ;;
        'help')
            koopa_defunct 'koopa --help'
            ;;
        'home' | \
        'prefix')
            koopa_defunct 'koopa system prefix'
            ;;
        'host-id')
            koopa_defunct 'koopa system host-id'
            ;;
        'info')
            koopa_defunct 'koopa system info'
            ;;
        'make-prefix')
            koopa_defunct 'koopa system prefix make'
            ;;
        'os-string')
            koopa_defunct 'koopa system os-string'
            ;;
        'r-home')
            koopa_defunct 'koopa system prefix r'
            ;;
        'roff')
            koopa_defunct 'koopa system roff'
            ;;
        'set-permissions')
            koopa_defunct 'koopa system set-permissions'
            ;;
        'test')
            koopa_defunct 'koopa system test'
            ;;
        'update-r-config')
            koopa_defunct 'koopa update r-config'
            ;;
        'upgrade')
            koopa_defunct 'koopa update'
            ;;
        'variable')
            koopa_defunct 'koopa system variable'
            ;;
        'variables')
            koopa_defunct 'koopa system variables'
            ;;
        'which-realpath')
            koopa_defunct 'koopa system which'
            ;;
        *)
            koopa_cli_invalid_arg "$@"
            ;;
    esac
    # Evaluate nested CLI runner function and reset positional arguments.
    if [[ "${dict[nested_runner]}"  -eq 1 ]]
    then
        local pos
        dict[fun]="koopa_${dict[key]//-/_}"
        koopa_assert_is_function "${dict[fun]}"
        readarray -t pos <<< "$("${dict[fun]}" "$@")"
        dict[key]="${pos[0]}"
        unset "pos[0]"
        if koopa_is_array_non_empty "${pos[@]:-}"
        then
            set -- "${pos[@]}"
        else
            set --
        fi
    fi
    # Check if user is requesting help, by evaluating last argument.
    case "${!#:-}" in
        '--help' | \
        '-h')
            koopa_help "$(koopa_man_prefix)/man1/${dict[key]}.1"
            ;;
    esac
    dict[fun]="$(koopa_which_function "${dict[key]}" || true)"
    if ! koopa_is_function "${dict[fun]}"
    then
        koopa_stop 'Unsupported command.'
    fi
    "${dict[fun]}" "$@"
    return 0
}
