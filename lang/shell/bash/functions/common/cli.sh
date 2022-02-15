#!/usr/bin/env bash

koopa::cli_app() { # {{{1
    # """
    # Parse user input to 'koopa app'.
    # @note Updated 2022-02-15.
    #
    # @examples
    # > koopa::cli_app 'aws' 'batch' 'fetch-and-run'
    # """
    local key
    case "${1:-}" in
        # Cross platform -------------------------------------------------------
        'aws')
            case "${2:-}" in
                'batch')
                    case "${3:-}" in
                        'fetch-and-run' | \
                        'list-jobs')
                            ;;
                        *)
                            koopa::invalid_arg "$*"
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
                            ;;
                        *)
                            koopa::invalid_arg "$*"
                        ;;
                    esac
                    ;;
                *)
                    koopa::invalid_arg "$*"
                    ;;
            esac
            key="${1:?}-${2:?}-${3:?}"
            shift 2
            ;;
        'conda')
            case "${2:-}" in
                'create-env' | \
                'remove-env')
                    ;;
                *)
                    koopa::invalid_arg "$*"
                    ;;
            esac
            key="${1:?}-${2:?}"
            shift 1
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
                    ;;
                *)
                    koopa::invalid_arg "$*"
                    ;;
            esac
            key="${1:?}-${2:?}"
            shift 1
            ;;
        'ftp')
            case "${2:-}" in
                'mirror')
                    ;;
                *)
                    koopa::invalid_arg "$*"
                    ;;
            esac
            key="${1:?}-${2:?}"
            shift 1
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
                    ;;
                *)
                    koopa::invalid_arg "$*"
                    ;;
            esac
            key="${1:?}-${2:?}"
            shift 1
            ;;
        'gpg')
            case "${2:-}" in
                'prompt' | \
                'reload' | \
                'restart')
                    ;;
                *)
                    koopa::invalid_arg "$*"
                    ;;
            esac
            key="${1:?}-${2:?}"
            shift 1
            ;;
        'jekyll')
            case "${2:-}" in
                'serve')
                    ;;
                *)
                    koopa::invalid_arg "$*"
                    ;;
            esac
            key="${1:?}-${2:?}"
            shift 1
            ;;
        'list')
            key='list-app-versions'
            ;;
        'md5sum')
            case "${2:-}" in
                'check-to-new-md5-file')
                    ;;
                *)
                    koopa::invalid_arg "$*"
                    ;;
            esac
            key="${1:?}-${2:?}"
            shift 1
            ;;
        'python')
            case "${2:-}" in
                'pip-outdated' | \
                'venv-create' | \
                'venv-create-r-reticulate')
                    ;;
                *)
                    koopa::invalid_arg "$*"
                    ;;
            esac
            key="${1:?}-${2:?}"
            shift 1
            ;;
        'r')
            case "${2:-}" in
                'drat' | \
                'pkgdown-deploy-to-aws' | \
                'shiny-run-app')
                    ;;
                *)
                    koopa::invalid_arg "$*"
                    ;;
            esac
            key="${1:?}-${2:?}"
            shift 1
            ;;
        'sra')
            case "${2:-}" in
                'download-accession-list' | \
                'download-run-info-table' | \
                'fastq-dump' | \
                'prefetch')
                    ;;
                *)
                    koopa::invalid_arg "$*"
                    ;;
            esac
            key="${1:?}-${2:?}"
            shift 1
            ;;
        'ssh')
            case "${2:-}" in
                'generate-key')
                    ;;
                *)
                    koopa::invalid_arg "$*"
                    ;;
            esac
            key="${1:?}-${2:?}"
            shift 1
            ;;
        'wget')
            case "${2:-}" in
                'recursive')
                    ;;
                *)
                    koopa::invalid_arg "$*"
                    ;;
            esac
            key="${1:?}-${2:?}"
            shift 1
            ;;
        # Linux-specifc --------------------------------------------------------
        'clean')
            key='delete-broken-app-symlinks'
            ;;
        'link')
            key='link-app'
            ;;
        'prune')
            key='prune-apps'
            ;;
        'unlink')
            key='unlink-app'
            ;;
        # Invalid --------------------------------------------------------------
        '')
            koopa::stop "Missing argument: 'koopa app <ARG>...'."
            ;;
        *)
            koopa::invalid_arg "$*"
            ;;
    esac
    shift 1
    koopa::print "$key" "$@"
    return 0
}

koopa::cli_configure() { # {{{1
    # """
    # Parse user input to 'koopa configure'.
    # @note Updated 2022-02-15.
    #
    # @examples
    # > koopa::cli_configure 'python'
    # """
    koopa::cli_nested_runner 'configure' "$@"
}

koopa::cli_install() { # {{{1
    # """
    # Parse user input to 'koopa install'.
    # @note Updated 2022-02-15.
    #
    # @examples
    # > koopa::cli_install 'python'
    # """
    koopa::cli_nested_runner 'install' "$@"
}

koopa::cli_list() { # {{{1
    # """
    # Parse user input to 'koopa list'.
    # @note Updated 2022-02-15.
    #
    # @examples
    # > koopa::cli_list 'dotfiles'
    # """
    koopa::cli_nested_runner 'list' "$@"
}

koopa::cli_nested_runner() { # {{{1
    # """
    # Nested CLI runner function.
    # @note Updated 2022-02-15.
    #
    # Used to standardize handoff handling of 'configure', 'install',
    # 'uninstall', and 'update' commands.
    # """
    local dict
    declare -A dict=(
        [runner]="${1:?}"
        [key]="${2:-}"
    )
    if [[ -z "${dict[key]}" ]]
    then
        koopa::stop "Missing argument: 'koopa ${dict[runner]} <ARG>...'."
    fi
    shift 2
    koopa::print "${dict[runner]}-${dict[key]}" "$@"
    return 0
}

koopa::cli_system() { # {{{1
    # """
    # Parse user input to 'koopa system'.
    # @note Updated 2022-02-15.
    # """
    local key
    case "${1:-}" in
        'check')
            key='check-system'
            ;;
        'info')
            key='system-info'
            ;;
        'log')
            key='view-latest-tmp-log-file'
            ;;
        'prefix')
            case "${2:-}" in
                '')
                    key='prefix'
                    ;;
                'koopa')
                    key='prefix'
                    shift 1
                    ;;
                *)
                    key="${2}-prefix"
                    shift 1
                    ;;
            esac
            ;;
        'homebrew-cask-version')
            key='get-homebrew-cask-version'
            ;;
        'macos-app-version')
            key='get-macos-app-version'
            ;;
        'version')
            key='get-version'
            ;;
        'which')
            key='which-realpath'
            ;;
        'brew-dump-brewfile' | \
        'brew-outdated' | \
        'delete-cache' | \
        'disable-passwordless-sudo' | \
        'disable-touch-id-sudo' | \
        'enable-passwordless-sudo' | \
        'enable-touch-id-sudo' | \
        'find-non-symlinked-make-files' | \
        'fix-sudo-setrlimit-error' | \
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
            ;;
        # Defunct --------------------------------------------------------------
        'conda-create-env')
            koopa::defunct 'koopa app conda create-env'
            ;;
        'conda-remove-env')
            koopa::defunct 'koopa app conda remove-env'
            ;;
        # Invalid --------------------------------------------------------------
        '')
            koopa::stop "Missing argument: 'koopa system <ARG>...'."
            ;;
        *)
            koopa::invalid_arg "$*"
            ;;
    esac
    shift 1
    koopa::print "$key" "$@"
    return 0
}

koopa::cli_uninstall() { # {{{1
    # """
    # Parse user input to 'koopa uninstall'.
    # @note Updated 2022-02-15.
    #
    # @seealso
    # > koopa::cli_uninstall 'python'
    # """
    koopa::cli_nested_runner 'uninstall' "$@"
}

koopa::cli_update() { # {{{1
    # """
    # Parse user input to 'koopa update'.
    # @note Updated 2022-02-15.
    #
    # @examples
    # > koopa::cli_update 'dotfiles'
    # """
    koopa::cli_nested_runner 'update' "$@"
}

koopa::koopa() { # {{{1
    # """
    # Main koopa CLI function, corresponding to 'koopa' binary.
    # @note Updated 2022-02-15.
    #
    # Need to update corresponding Bash completion file in
    # 'etc/completion/koopa.sh'.
    # """
    local dict
    koopa::assert_has_args "$#"
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
            koopa::defunct 'koopa system prefix app'
            ;;
        'cellar-prefix')
            koopa::defunct 'koopa system prefix app'
            ;;
        'check' | \
        'check-system')
            koopa::defunct 'koopa system check'
            ;;
        'conda-prefix')
            koopa::defunct 'koopa system prefix conda'
            ;;
        'config-prefix')
            koopa::defunct 'koopa system prefix config'
            ;;
        'delete-cache')
            koopa::defunct 'koopa system delete-cache'
            ;;
        'fix-zsh-permissions')
            koopa::defunct 'koopa system fix-zsh-permissions'
            ;;
        'get-homebrew-cask-version')
            koopa::defunct 'koopa system homebrew-cask-version'
            ;;
        'get-macos-app-version')
            koopa::defunct 'koopa system macos-app-version'
            ;;
        'get-version')
            koopa::defunct 'koopa system version'
            ;;
        'help')
            koopa::defunct 'koopa --help'
            ;;
        'home' | \
        'prefix')
            koopa::defunct 'koopa system prefix'
            ;;
        'host-id')
            koopa::defunct 'koopa system host-id'
            ;;
        'info')
            koopa::defunct 'koopa system info'
            ;;
        'make-prefix')
            koopa::defunct 'koopa system prefix make'
            ;;
        'os-string')
            koopa::defunct 'koopa system os-string'
            ;;
        'r-home')
            koopa::defunct 'koopa system prefix r'
            ;;
        'roff')
            koopa::defunct 'koopa system roff'
            ;;
        'set-permissions')
            koopa::defunct 'koopa system set-permissions'
            ;;
        'test')
            koopa::defunct 'koopa system test'
            ;;
        'update-r-config')
            koopa::defunct 'koopa update r-config'
            ;;
        'upgrade')
            koopa::defunct 'koopa update'
            ;;
        'variable')
            koopa::defunct 'koopa system variable'
            ;;
        'variables')
            koopa::defunct 'koopa system variables'
            ;;
        'which-realpath')
            koopa::defunct 'koopa system which'
            ;;
        *)
            koopa::invalid_arg "$*"
            ;;
    esac
    dict[fun]="koopa::${dict[key]//-/_}"
    koopa::assert_is_function "${dict[fun]}"
    # Evaluate nested CLI runner function and reset positional arguments.
    if [[ "${dict[nested_runner]}"  -eq 1 ]]
    then
        local pos
        koopa::assert_is_function "${dict[fun]}"
        readarray -t pos <<< "$("${dict[fun]}" "$@")"
        dict[key]="${pos[0]}"
        dict[fun]="koopa::${dict[key]//-/_}"
        koopa::assert_is_function "${dict[fun]}"
        unset "pos[0]"
        set -- "${pos[@]:-}"
    fi
    # Check if user is requesting help, by evaluating last argument.
    case "${!#:-}" in
        '--help' | \
        '-h')
            dict[koopa_prefix]="$(koopa::koopa_prefix)"
            dict[man_file]="${dict[koopa_prefix]}/man/man1/${dict[key]}.1"
            koopa::help "${dict[man_file]}"
            ;;
    esac
    "${dict[fun]}" "$@"
    return 0
}
