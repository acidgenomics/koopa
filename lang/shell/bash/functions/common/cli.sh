#!/usr/bin/env bash

koopa_cli_app() { # {{{1
    # """
    # Parse user input to 'koopa app'.
    # @note Updated 2022-03-17.
    #
    # @examples
    # > koopa_cli_app 'aws' 'batch' 'fetch-and-run'
    # """
    local key
    case "${1:-}" in
        # Help documentation ---------------------------------------------------
        '--help' | \
        '-h')
            koopa_help "$(koopa_man_prefix)/man1/app.1"
            ;;
        # Cross platform -------------------------------------------------------
        'aws')
            case "${2:-}" in
                'batch')
                    case "${3:-}" in
                        'fetch-and-run' | \
                        'list-jobs')
                            key="${1:?}-${2:?}-${3:?}"
                            shift 3
                            ;;
                        *)
                            koopa_invalid_arg "$*"
                        ;;
                    esac
                    ;;
                'ec2')
                    case "${3:-}" in
                        'create-instance' | \
                        'instance-id' | \
                        'suspend-instance' | \
                        'terminate-instance')
                            key="${1:?}-${2:?}-${3:?}"
                            shift 3
                            ;;
                        *)
                            koopa_invalid_arg "$*"
                        ;;
                    esac
                    ;;
                's3')
                    case "${3:-}" in
                        'find' | \
                        'list-large-files' | \
                        'ls' | \
                        'mv-to-parent' | \
                        'sync')
                            key="${1:?}-${2:?}-${3:?}"
                            shift 3
                            ;;
                        *)
                            koopa_invalid_arg "$*"
                        ;;
                    esac
                    ;;
                *)
                    koopa_invalid_arg "$*"
                    ;;
            esac
            ;;
        'conda')
            case "${2:-}" in
                'create-env' | \
                'remove-env')
                    key="${1:?}-${2:?}"
                    shift 2
                    ;;
                *)
                    koopa_invalid_arg "$*"
                    ;;
            esac
            ;;
        'docker')
            case "${2:-}" in
                'build' | \
                'build-all-images' | \
                'build-all-tags' | \
                'prune-all-images' | \
                'prune-all-stale-tags' | \
                'prune-old-images' | \
                'prune-stale-tags' | \
                'push' | \
                'remove' | \
                'run' | \
                'tag')
                    key="${1:?}-${2:?}"
                    shift 2
                    ;;
                *)
                    koopa_invalid_arg "$*"
                    ;;
            esac
            ;;
        'ftp')
            case "${2:-}" in
                'mirror')
                    key="${1:?}-${2:?}"
                    shift 2
                    ;;
                *)
                    koopa_invalid_arg "$*"
                    ;;
            esac
            ;;
        'git')
            case "${2:-}" in
                'checkout-recursive' | \
                'pull' | \
                'pull-recursive' | \
                'push-recursive' | \
                'push-submodules' | \
                'rename-master-to-main' | \
                'reset' | \
                'reset-fork-to-upstream' | \
                'rm-submodule' | \
                'rm-untracked' | \
                'status-recursive')
                    key="${1:?}-${2:?}"
                    shift 2
                    ;;
                *)
                    koopa_invalid_arg "$*"
                    ;;
            esac
            ;;
        'gpg')
            case "${2:-}" in
                'prompt' | \
                'reload' | \
                'restart')
                    key="${1:?}-${2:?}"
                    shift 2
                    ;;
                *)
                    koopa_invalid_arg "$*"
                    ;;
            esac
            ;;
        'jekyll')
            case "${2:-}" in
                'serve')
                    key="${1:?}-${2:?}"
                    shift 2
                    ;;
                *)
                    koopa_invalid_arg "$*"
                    ;;
            esac
            ;;
        'kallisto' | \
        'salmon')
            case "${2:-}" in
                'index')
                    key="${1:?}-${2:?}"
                    shift 2
                    ;;
                # FIXME Double check that this works.
                'quant')
                    case "${3:-}" in
                        'paired-end' | \
                        'single-end')
                            key="${1:?}-${2:?}-${3:?}"
                            shift 3
                            ;;
                        *)
                            koopa_invalid_arg "$*"
                        ;;
                    esac
                    ;;
                *)
                    koopa_invalid_arg "$*"
                    ;;
            esac
            ;;
        'list')
            key='list-app-versions'
            shift 1
            ;;
        'md5sum')
            case "${2:-}" in
                'check-to-new-md5-file')
                    key="${1:?}-${2:?}"
                    shift 2
                    ;;
                *)
                    koopa_invalid_arg "$*"
                    ;;
            esac
            ;;
        'python')
            case "${2:-}" in
                'create-venv')
                    case "${3:-}" in
                        'r-reticulate')
                            key="${1:?}-${2:?}-${3:?}"
                            shift 3
                            ;;
                        *)
                            key="${1:?}-${2:?}"
                            shift 2
                            ;;
                    esac
                    ;;
                'pip-outdated')
                    key="${1:?}-${2:?}"
                    shift 2
                    ;;
                *)
                    koopa_invalid_arg "$*"
                    ;;
            esac
            ;;
        'r')
            case "${2:-}" in
                'drat' | \
                'pkgdown-deploy-to-aws' | \
                'shiny-run-app')
                    key="${1:?}-${2:?}"
                    shift 2
                    ;;
                *)
                    koopa_invalid_arg "$*"
                    ;;
            esac
            ;;
        'sra')
            case "${2:-}" in
                'download-accession-list' | \
                'download-run-info-table' | \
                'fastq-dump' | \
                'prefetch')
                    key="${1:?}-${2:?}"
                    shift 2
                    ;;
                *)
                    koopa_invalid_arg "$*"
                    ;;
            esac
            ;;
        'ssh')
            case "${2:-}" in
                'generate-key')
                    key="${1:?}-${2:?}"
                    shift 2
                    ;;
                *)
                    koopa_invalid_arg "$*"
                    ;;
            esac
            ;;
        'wget')
            case "${2:-}" in
                'recursive')
                    key="${1:?}-${2:?}"
                    shift 2
                    ;;
                *)
                    koopa_invalid_arg "$*"
                    ;;
            esac
            ;;
        # Linux-specifc --------------------------------------------------------
        'clean')
            key='delete-broken-app-symlinks'
            shift 1
            ;;
        'link')
            key='link-app'
            shift 1
            ;;
        'prune')
            key='prune-apps'
            shift 1
            ;;
        'unlink')
            key='unlink-app'
            shift 1
            ;;
        # Invalid --------------------------------------------------------------
        '')
            koopa_stop "Missing argument: 'koopa app <ARG>...'."
            ;;
        *)
            koopa_invalid_arg "$*"
            ;;
    esac
    koopa_print "$key" "$@"
    return 0
}

koopa_cli_configure() { # {{{1
    # """
    # Parse user input to 'koopa configure'.
    # @note Updated 2022-02-15.
    #
    # @examples
    # > koopa_cli_configure 'python'
    # """
    koopa_cli_nested_runner 'configure' "$@"
}

koopa_cli_install() { # {{{1
    # """
    # Parse user input to 'koopa install'.
    # @note Updated 2022-02-15.
    #
    # @examples
    # > koopa_cli_install 'python'
    # """
    koopa_cli_nested_runner 'install' "$@"
}

koopa_cli_list() { # {{{1
    # """
    # Parse user input to 'koopa list'.
    # @note Updated 2022-02-15.
    #
    # @examples
    # > koopa_cli_list 'dotfiles'
    # """
    koopa_cli_nested_runner 'list' "$@"
}

koopa_cli_nested_runner() { # {{{1
    # """
    # Nested CLI runner function.
    # @note Updated 2022-02-16.
    #
    # Used to standardize handoff handling of 'configure', 'install',
    # 'uninstall', and 'update' commands.
    # """
    local dict
    declare -A dict=(
        [runner]="${1:?}"
        [key]="${2:-}"
    )
    case "${dict[key]}" in
        '')
            koopa_stop "Missing argument: 'koopa ${dict[runner]} <ARG>...'."
            ;;
        '--help' | \
        '-h')
            koopa_help "$(koopa_man_prefix)/man/man1/${dict[runner]}.1"
            ;;
        '-'*)
            koopa_invalid_arg "$*"
            ;;
        *)
            shift 2
            ;;
    esac
    koopa_print "${dict[runner]}-${dict[key]}" "$@"
    return 0
}

koopa_cli_system() { # {{{1
    # """
    # Parse user input to 'koopa system'.
    # @note Updated 2022-02-16.
    # """
    local key
    key=''
    # Platform independent.
    case "${1:-}" in
        '')
            koopa_stop "Missing argument: 'koopa system <ARG>...'."
            ;;
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
        'disable-passwordless-sudo' | \
        'enable-passwordless-sudo' | \
        'find-non-symlinked-make-files' | \
        'fix-zsh-permissions' | \
        'host-id' | \
        'os-string' | \
        'reload-shell' | \
        'roff' | \
        'set-permissions' | \
        'switch-to-develop' | \
        'test' | \
        'variable' | \
        'variables')
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
                'homebrew-cask-version')
                    key='get-homebrew-cask-version'
                    shift 1
                    ;;
                'macos-app-version')
                    key='get-macos-app-version'
                    shift 1
                    ;;
                'clean-launch-services' | \
                'disable-touch-id-sudo' | \
                'enable-touch-id-sudo' | \
                'flush-dns' | \
                'ifactive' | \
                'list-launch-agents' | \
                'reload-autofs')
                    key="${1:?}"
                    shift 1
                    ;;
            esac
        fi
    fi
    [[ -z "$key" ]] && koopa_invalid_arg "$*"
    koopa_print "$key" "$@"
    return 0
}

koopa_cli_uninstall() { # {{{1
    # """
    # Parse user input to 'koopa uninstall'.
    # @note Updated 2022-02-15.
    #
    # @seealso
    # > koopa_cli_uninstall 'python'
    # """
    koopa_cli_nested_runner 'uninstall' "$@"
}

koopa_cli_update() { # {{{1
    # """
    # Parse user input to 'koopa update'.
    # @note Updated 2022-03-09.
    #
    # @examples
    # > koopa_cli_update 'dotfiles'
    # """
    [[ "$#" -eq 0 ]] && set -- 'koopa'
    koopa_cli_nested_runner 'update' "$@"
}

koopa_koopa() { # {{{1
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
        # Nested CLI runners {{{2
        # ----------------------------------------------------------------------
        'app' | \
        'configure' | \
        'install' | \
        'link' | \
        'list' | \
        'system' | \
        'uninstall' | \
        'update')
            dict[nested_runner]=1
            dict[key]="cli-${1}"
            shift 1
            ;;
        # Defunct args / error catching {{{2
        # ----------------------------------------------------------------------
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
            koopa_invalid_arg "$*"
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
    # FIXME This is failing to locate 'install-base-system' on Ubuntu.
    dict[fun]="$(koopa_which_function "${dict[key]}" || true)"
    if ! koopa_is_function "${dict[fun]}"
    then
        koopa_stop 'Unsupported command.'
    fi
    "${dict[fun]}" "$@"
    return 0
}
