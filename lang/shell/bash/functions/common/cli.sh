#!/usr/bin/env bash

koopa::cli_app() { # {{{1
    # """
    # Parse user input to 'koopa app'.
    # @note Updated 2022-02-10.
    # """
    local key
    case "${1:-}" in
        # Cross platform -------------------------------------------------------
        'aws' | \
        'conda')
            key="${1:?}-${2:?}"
            shift 1
            ;;
        'list')
            key='list-app-versions'
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
    koopa::cli_run_function "$key" "$@"
    return 0
}

koopa::cli_configure() { # {{{1
    # """
    # Parse user input to 'koopa configure'.
    # @note Updated 2022-02-02.
    # """
    local key
    key="${1:-}"
    if [[ -z "$key" ]]
    then
        koopa::stop "Missing argument: 'koopa configure <ARG>...'."
    fi
    shift 1
    koopa::cli_run_function "configure-${key}" "$@"
    return 0
}

koopa::cli_header() { # {{{1
    # """
    # Parse user input to 'koopa header'.
    # @note Updated 2022-02-02.
    #
    # Useful for private scripts using koopa code outside of package.
    # """
    local dict
    koopa::assert_has_args_eq "$#" 1
    declare -A dict=(
        [lang]="$(koopa::lowercase "${1:?}")"
        [prefix]="$(koopa::koopa_prefix)/lang"
    )
    case "${dict[lang]}" in
        'bash' | \
        'posix' | \
        'zsh')
            dict[prefix]="${dict[prefix]}/shell"
            dict[ext]='sh'
            ;;
        'r')
            dict[ext]='R'
            ;;
        *)
            koopa::invalid_arg "${dict[lang]}"
            ;;
    esac
    dict[file]="${dict[prefix]}/${dict[lang]}/include/header.${dict[ext]}"
    koopa::assert_is_file "${dict[file]}"
    koopa::print "${dict[file]}"
    return 0
}

koopa::cli_install() { # {{{1
    # """
    # Parse user input to 'koopa install'.
    # @note Updated 2022-02-02.
    # """
    local app app_args apps denylist pos
    app_args=()
    denylist=('app' 'gnu-app')
    pos=()
    while (("$#"))
    do
        case "$1" in
            '')
                shift 1
                ;;
            '--'*)
                app_args+=("$1")
                shift 1
                ;;
            '-'*)
                koopa::invalid_arg "$1"
                ;;
            *)
                pos+=("$1")
                shift 1
                ;;
        esac
    done
    [[ "${#pos[@]}" -gt 0 ]] && set -- "${pos[@]}"
    if [[ "$#" -eq 0 ]]
    then
        koopa::stop "Missing argument: 'koopa install <ARG>...'."
    fi
    apps=("$@")
    for app in "${apps[@]}"
    do
        if koopa::contains "$app" "${denylist[@]}"
        then
            koopa::stop "Invalid argument: '${app}'."
        fi
    done
    for app in "${apps[@]}"
    do
        koopa::cli_run_function "install-${app}" "${app_args[@]}"
    done
    return 0
}

koopa::cli_list() { # {{{1
    # """
    # Parse user input to 'koopa list'.
    # @note Updated 2022-02-02.
    # """
    local key
    key="${1:-}"
    if [[ -z "$key" ]]
    then
        key='list'
    else
        key="list-${key}"
        shift 1
    fi
    koopa::cli_run_function "$key" "$@"
    return 0
}

koopa::cli_system() { # {{{1
    # """
    # Parse user input to 'koopa system'.
    # @note Updated 2022-02-10.
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
        'path')
            koopa::print "${PATH:-}"
            return 0
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
        'roff' | \
        'set-permissions' | \
        'switch-to-develop' | \
        'test' | \
        'variable' | \
        'variables')
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
    koopa::cli_run_function "$key" "$@"
    return 0
}

koopa::cli_uninstall() { # {{{1
    # """
    # Parse user input to 'koopa uninstall'.
    # @note Updated 2022-02-02.
    # """
    local app app_args apps denylist pos
    app_args=()
    denylist=('app')
    pos=()
    while (("$#"))
    do
        case "$1" in
            '')
                shift 1
                ;;
            '--'*)
                app_args+=("$1")
                shift 1
                ;;
            '-'*)
                koopa::invalid_arg "$1"
                ;;
            *)
                pos+=("$1")
                shift 1
                ;;
        esac
    done
    [[ "${#pos[@]}" -gt 0 ]] && set -- "${pos[@]}"
    if [[ "$#" -eq 0 ]]
    then
        koopa::stop "Missing argument: 'koopa uninstall <ARG>...'."
    fi
    apps=("$@")
    for app in "${apps[@]}"
    do
        if koopa::contains "$app" "${denylist[@]}"
        then
            koopa::stop "Invalid argument: '${app}'."
        fi
    done
    for app in "${apps[@]}"
    do
        koopa::cli_run_function "uninstall-${app}" "${app_args[@]}"
    done
    return 0
}

koopa::cli_update() { # {{{1
    # """
    # Parse user input to 'koopa update'.
    # @note Updated 2022-02-02.
    # """
    local app app_args apps denylist pos
    app_args=()
    denylist=('app')
    pos=()
    while (("$#"))
    do
        case "$1" in
            # Defunct ----------------------------------------------------------
            '--fast')
                koopa::defunct 'koopa update'
                ;;
            '--source-ip='* | \
            '--source-ip')
                koopa::defunct 'koopa configure system --source-ip=SOURCE_IP'
                ;;
            '--system')
                koopa::defunct 'koopa update system'
                ;;
            '--user')
                koopa::defunct 'koopa update user'
                ;;
            # General catchers -------------------------------------------------
            '')
                shift 1
                ;;
            '--'*)
                app_args+=("$1")
                shift 1
                ;;
            '-'*)
                koopa::invalid_arg "$1"
                ;;
            *)
                pos+=("$1")
                shift 1
                ;;
        esac
    done
    # Pass to 'koopa::update_koopa' by default.
    [[ "${#pos[@]}" -eq 0 ]] && pos=('koopa')
    [[ "${#pos[@]}" -gt 0 ]] && set -- "${pos[@]}"
    if [[ "$#" -eq 0 ]]
    then
        koopa::stop "Missing argument: 'koopa update <ARG>...'."
    fi
    apps=("$@")
    for app in "${apps[@]}"
    do
        if koopa::contains "$app" "${denylist[@]}"
        then
            koopa::stop "Invalid argument: '${app}'."
        fi
    done
    for app in "${apps[@]}"
    do
        koopa::cli_run_function "update-${app}" "${app_args[@]}"
    done
    return 0
}

koopa::cli_run_function() { # {{{1
    # """
    # Lookup and execute a koopa function automatically.
    # @note Updated 2022-02-02.
    # """
    local dict
    koopa::assert_has_args "$#"
    declare -A dict=(
        [name]="${1:?}"
    )
    dict[fun]="$(koopa::cli_which_function "${dict[name]}")"
    koopa::assert_is_function "${dict[fun]}"
    shift 1
    "${dict[fun]}" "$@"
    return 0
}

koopa::cli_which_function() { # {{{1
    # """
    # Locate a koopa function automatically.
    # @note Updated 2022-02-02.
    # """
    local fun key os_id
    koopa::assert_has_args_eq "$#" 1
    key="${1:?}"
    if koopa::is_function "${key}"
    then
        koopa::print "$key"
        return 0
    fi
    fun="${key//-/_}"
    os_id="$(koopa::os_id)"
    if koopa::is_function "koopa::${os_id}_${fun}"
    then
        fun="koopa::${os_id}_${fun}"
    elif koopa::is_rhel_like && \
        koopa::is_function "koopa::rhel_${fun}"
    then
        fun="koopa::rhel_${fun}"
    elif koopa::is_debian_like && \
        koopa::is_function "koopa::debian_${fun}"
    then
        fun="koopa::debian_${fun}"
    elif koopa::is_fedora_like && \
        koopa::is_function "koopa::fedora_${fun}"
    then
        fun="koopa::fedora_${fun}"
    elif koopa::is_linux && \
        koopa::is_function "koopa::linux_${fun}"
    then
        fun="koopa::linux_${fun}"
    else
        fun="koopa::${fun}"
    fi
    if ! koopa::is_function "$fun"
    then
        koopa::stop "Unsupported command: '${key}'."
    fi
    koopa::print "$fun"
    return 0
}

koopa::koopa() { # {{{1
    # """
    # Main koopa CLI function, corresponding to 'koopa' binary.
    # @note Updated 2022-02-10.
    #
    # Need to update corresponding Bash completion file in
    # 'etc/completion/koopa.sh'.
    # """
    local fun key
    koopa::assert_has_args "$#"
    case "${1:?}" in
        '--version' | \
        '-V' | \
        'version')
            key='koopa-version'
            shift 1
            ;;
        'reinstall')
            key='reinstall-app'
            shift 1
            ;;
        'app' | \
        'configure' | \
        'header' | \
        'install' | \
        'link' | \
        'list' | \
        'system' | \
        'uninstall' | \
        'update')
            key="cli-${1}"
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
    fun="koopa::${key//-/_}"
    koopa::assert_is_function "$fun"
    "$fun" "$@"
    return 0
}
