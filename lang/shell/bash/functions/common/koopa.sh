#!/usr/bin/env bash

koopa:::koopa_app() { # {{{1
    # """
    # Parse user input to 'koopa app'.
    # @note Updated 2021-03-01.
    # """
    local name
    name="${1:-}"
    if [[ -z "$name" ]]
    then
        koopa::stop "Missing argument: 'koopa app <ARG>...'."
    fi
    case "$name" in
        clean)
            name='delete-broken-app-symlinks'
            ;;
        list)
            name='list-app-versions'
            ;;
        link)
            name='link-app'
            ;;
        prune)
            name='prune-apps'
            ;;
        unlink)
            name='unlink-app'
            ;;
    esac
    shift 1
    koopa:::run_function "$name" "$@"
    return 0
}

koopa:::koopa_configure() { # {{{1
    # """
    # Parse user input to 'koopa configure'.
    # @note Updated 2021-04-29.
    # """
    local name
    name="${1:-}"
    if [[ -z "$name" ]]
    then
        koopa::stop "Missing argument: 'koopa configure <ARG>...'."
    fi
    shift 1
    koopa:::run_function "configure-${name}" "$@"
    return 0
}

koopa:::koopa_header() { # {{{1
    # """
    # Parse user input to 'koopa header'.
    # @note Updated 2021-01-19.
    #
    # Useful for private scripts using koopa code outside of package.
    # """
    local arg ext file koopa_prefix subdir
    koopa::assert_has_args_eq "$#" 1
    arg="$(koopa::lowercase "${1:?}")"
    koopa_prefix="$(koopa::prefix)"
    subdir='lang'
    case "$arg" in
        bash|posix|zsh)
            subdir="${subdir}/shell"
            ext='sh'
            ;;
        r)
            ext='R'
            ;;
        *)
            koopa::invalid_arg "$arg"
            ;;
    esac
    file="${koopa_prefix}/${subdir}/${arg}/include/header.${ext}"
    koopa::assert_is_file "$file"
    koopa::print "$file"
    return 0
}

koopa:::koopa_install() { # {{{1
    # """
    # Parse user input to 'koopa install'.
    # @note Updated 2021-05-07.
    # """
    local app app_args apps denylist pos
    app_args=()
    pos=()
    readarray -t denylist <<< "$(koopa:::koopa_install_denylist)"
    while (("$#"))
    do
        case "$1" in
            --*|-*)
                app_args+=("$1")
                shift 1
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
        koopa:::run_function "install-${app}" "${app_args[@]}"
    done
    return 0
}

koopa:::koopa_install_denylist() {
    # """
    # App names that are intentionally not supported.
    # @note Updated 2021-05-07.
    # """
    local names
    names=(
        'app'
        'gnu-app'
        'start'
        'success'
    )
    koopa::print "${names[@]}"
}

koopa:::koopa_link() { # {{{1
    # """
    # Parse user input to 'koopa link'.
    # @note Updated 2021-03-01.
    # """
    local name
    name="${1:-}"
    if [[ -z "$name" ]]
    then
        koopa::stop "Missing argument: 'koopa link <ARG>...'."
    fi
    shift 1
    koopa:::run_function "link-${name}" "$@"
    return 0
}

koopa:::koopa_list() { # {{{1
    # """
    # Parse user input to 'koopa list'.
    # @note Updated 2021-03-01.
    # """
    local name
    name="${1:-}"
    if [[ -z "$name" ]]
    then
        name='list'
    else
        name="list-${name}"
        shift 1
    fi
    koopa:::run_function "$name" "$@"
    return 0
}

koopa:::koopa_system() { # {{{1
    # """
    # Parse user input to 'koopa system'.
    # @note Updated 2021-03-01.
    # """
    local f
    f="${1:-}"
    if [[ -z "$f" ]]
    then
        koopa::stop "Missing argument: 'koopa system <ARG>...'."
    fi
    case "$f" in
        check)
            f='check-system'
            ;;
        info)
            f='sys-info'
            ;;
        log)
            f='view-latest-tmp-log-file'
            ;;
        path)
            koopa::print "$PATH"
            return 0
            ;;
        prefix)
            case "${2:-}" in
                '')
                    f='prefix'
                    ;;
                koopa)
                    f='prefix'
                    shift 1
                    ;;
                *)
                    f="${2}-prefix"
                    shift 1
                    ;;
            esac
            ;;
        pull)
            f='sys-git-pull'
            ;;
        homebrew-cask-version)
            f='get-homebrew-cask-version'
            ;;
        macos-app-version)
            f='get-macos-app-version'
            ;;
        version)
            f='get-version'
            ;;
        which)
            f='which-realpath'
            ;;
        brew-dump-brewfile | \
        brew-outdated | \
        delete-cache | \
        disable-passwordless-sudo | \
        disable-touch-id-sudo | \
        enable-passwordless-sudo | \
        enable-touch-id-sudo | \
        fix-sudo-setrlimit-error | \
        fix-zsh-permissions | \
        host-id | \
        os-string | \
        roff | \
        set-permissions | \
        variable | \
        variables)
            ;;
        *)
            koopa::invalid_arg "$*"
            ;;
    esac
    shift 1
    koopa:::run_function "$f" "$@"
    return 0
}

koopa:::koopa_uninstall() { # {{{1
    # """
    # Parse user input to 'koopa uninstall'.
    # @note Updated 2021-03-01.
    # """
    local name
    name="${1:-}"
    if [[ -z "$name" ]]
    then
        koopa::stop 'Program name to uninstall is required.'
    fi
    koopa:::run_function "uninstall-${name}"
    return 0
}

koopa:::koopa_update() { # {{{1
    # """
    # Parse user input to 'koopa update'.
    # @note Updated 2021-03-01.
    # """
    local name
    name="${1:-}"
    case "$name" in
        '')
            name='koopa'
            ;;
        system|user)
            name="koopa-${name}"
            ;;
        # Defunct --------------------------------------------------------------
        --fast)
            koopa::defunct 'koopa update'
            ;;
        --source-ip=*)
            koopa::defunct 'koopa configure-vm --source-ip=SOURCE_IP'
            ;;
        --system)
            koopa::defunct 'koopa update system'
            ;;
        --user)
            koopa::defunct 'koopa update user'
            ;;
    esac
    [[ "$#" -gt 0 ]] && shift 1
    koopa:::run_function "update-${name}" "$@"
    return 0
}

koopa:::run_function() { # {{{1
    # """
    # Lookup and execute a koopa function automatically.
    # @note Updated 2020-11-18.
    # """
    local name fun
    koopa::assert_has_args "$#"
    name="${1:?}"
    fun="$(koopa:::which_function "$name")"
    koopa::assert_is_function "$fun"
    shift 1
    "$fun" "$@"
    return 0
}

koopa:::which_function() { # {{{1
    # """
    # Locate a koopa function automatically.
    # @note Updated 2020-11-30.
    # """
    local f fun os_id
    koopa::assert_has_args_eq "$#" 1
    f="${1:?}"
    f="${f//-/_}"
    os_id="$(koopa::os_id)"
    if koopa::is_function "koopa::${os_id}_${f}"
    then
        fun="koopa::${os_id}_${f}"
    elif koopa::is_rhel_like && \
        koopa::is_function "koopa::rhel_${f}"
    then
        fun="koopa::rhel_${f}"
    elif koopa::is_debian_like && \
        koopa::is_function "koopa::debian_${f}"
    then
        fun="koopa::debian_${f}"
    elif koopa::is_fedora_like && \
        koopa::is_function "koopa::fedora_${f}"
    then
        fun="koopa::fedora_${f}"
    elif koopa::is_linux && \
        koopa::is_function "koopa::linux_${f}"
    then
        fun="koopa::linux_${f}"
    else
        fun="koopa::${f}"
    fi
    if ! koopa::is_function "$fun"
    then
        koopa::stop 'Unsupported command.'
    fi
    koopa::print "$fun"
    return 0
}

koopa::koopa() { # {{{1
    # """
    # Main koopa function, corresponding to 'koopa' binary.
    # @note Updated 2021-05-04.
    #
    # Need to update corresponding Bash completion file in
    # 'etc/completion/koopa.sh'.
    # """
    koopa::assert_has_args "$#"
    case "$1" in
        --version|-V)
            f='version'
            shift 1
            ;;
        app | \
        configure | \
        header | \
        install | \
        link | \
        list | \
        system | \
        uninstall | \
        update)
            # Note that the ':' is necessary here to call the internal functions
            # defined above.
            f=":koopa_${1}"
            shift 1
            ;;
        test)
            f="$1"
            shift 1
            ;;
        # Soft deprecated args {{{2
        # ----------------------------------------------------------------------
        check | \
        check-system)
            f='check-system'
            shift 1
            ;;
        home)
            f='prefix'
            shift 1
            ;;
        info)
            f='sys-info'
            shift 1
            ;;
        prefix | \
        version)
            f="$1"
            shift 1
            ;;
        # Defunct args / error catching {{{2
        # ----------------------------------------------------------------------
        app-prefix)
            koopa::defunct 'koopa system prefix app'
            ;;
        cellar-prefix)
            koopa::defunct 'koopa system prefix app'
            ;;
        conda-prefix)
            koopa::defunct 'koopa system prefix conda'
            ;;
        config-prefix)
            koopa::defunct 'koopa system prefix config'
            ;;
        delete-cache)
            koopa::defunct 'koopa system delete-cache'
            ;;
        fix-zsh-permissions)
            koopa::defunct 'koopa system fix-zsh-permissions'
            ;;
        get-homebrew-cask-version)
            koopa::defunct 'koopa system homebrew-cask-version'
            ;;
        get-macos-app-version)
            koopa::defunct 'koopa system macos-app-version'
            ;;
        get-version)
            koopa::defunct 'koopa system version'
            ;;
        help)
            koopa::defunct 'koopa --help'
            ;;
        host-id)
            koopa::defunct 'koopa system host-id'
            ;;
        make-prefix)
            koopa::defunct 'koopa system prefix make'
            ;;
        os-string)
            koopa::defunct 'koopa system os-string'
            ;;
        r-home)
            koopa::defunct 'koopa system prefix r'
            ;;
        roff)
            koopa::defunct 'koopa system roff'
            ;;
        set-permissions)
            koopa::defunct 'koopa system set-permissions'
            ;;
        update-r-config)
            koopa::defunct 'koopa update r-config'
            ;;
        upgrade)
            koopa::defunct 'koopa update'
            ;;
        variable)
            koopa::defunct 'koopa system variable'
            ;;
        variables)
            koopa::defunct 'koopa system variables'
            ;;
        which-realpath)
            koopa::defunct 'koopa system which'
            ;;
        *)
            koopa::invalid_arg "$*"
            ;;
    esac
    fun="koopa::${f//-/_}"
    koopa::assert_is_function "$fun"
    "$fun" "$@"
    return 0
}
