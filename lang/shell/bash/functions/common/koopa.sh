#!/usr/bin/env bash

# NOTE Need to add support for 'link' here in a future release.

koopa::_koopa_app() { # {{{1
    # """
    # Parse user input to 'koopa app'.
    # @note Updated 2021-01-19.
    # """
    local name
    name="${1:-}"
    if [[ -z "$name" ]]
    then
        koopa::stop "Missing argument: 'koopa app <ARG>...'."
    fi
    case "$name" in
        clean)
            name='delete_broken_app_symlinks'
            ;;
        list)
            name='list_app_versions'
            ;;
        link)
            name='link_app'
            ;;
        prune)
            name='prune_apps'
            ;;
        unlink)
            name='unlink_app'
            ;;
    esac
    shift 1
    koopa::_run_function "$name" "$@"
    return 0
}

koopa::_koopa_header() { # {{{1
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

# NOTE Consider hardening against 'koopa::install_app' here.
koopa::_koopa_install() { # {{{1
    # """
    # Parse user input to 'koopa install'.
    # @note Updated 2020-12-31.
    # """
    local name
    name="${1:-}"
    if [[ -z "$name" ]]
    then
        koopa::stop "Missing argument: 'koopa install <ARG>...'."
    fi
    shift 1
    koopa::_run_function "install_${name}" "$@"
    return 0
}

koopa::_koopa_link() { # {{{1
    # """
    # Parse user input to 'koopa link'.
    # @note Updated 2020-12-31.
    # """
    local name
    name="${1:-}"
    [[ -z "$name" ]] && koopa::invalid_arg
    shift 1
    koopa::_run_function "link_${name}" "$@"
    return 0
}

koopa::_koopa_list() { # {{{1
    # """
    # Parse user input to 'koopa list'.
    # @note Updated 2020-12-31.
    # """
    local name
    name="${1:-}"
    if [[ -z "$name" ]]
    then
        name='list'
    else
        name="list_${name}"
        shift 1
    fi
    koopa::_run_function "$name" "$@"
    return 0
}

koopa::_koopa_uninstall() { # {{{1
    # """
    # Parse user input to 'koopa uninstall'.
    # @note Updated 2020-12-31.
    # """
    local name
    name="${1:-}"
    if [[ -z "$name" ]]
    then
        koopa::stop 'Program name to uninstall is required.'
    fi
    koopa::_run_function "uninstall_${name}"
    return 0
}

koopa::_koopa_update() { # {{{1
    # """
    # Parse user input to 'koopa update'.
    # @note Updated 2021-01-19.
    # """
    local name
    name="${1:-}"
    case "$name" in
        '')
            name='koopa'
            ;;
        system|user)
            name="koopa_${name}"
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
    koopa::_run_function "update_${name}" "$@"
    return 0
}

koopa::_run_function() { # {{{1
    # """
    # Lookup and execute a koopa function automatically.
    # @note Updated 2020-11-18.
    # """
    local name fun
    koopa::assert_has_args "$#"
    name="${1:?}"
    fun="$(koopa::_which_function "$name")"
    koopa::assert_is_function "$fun"
    shift 1
    "$fun" "$@"
    return 0
}

koopa::_which_function() { # {{{1
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
    # @note Updated 2020-12-31.
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
        header | \
        install | \
        link | \
        list | \
        uninstall | \
        update)
            f="_koopa_${1}"
            shift 1
            ;;
        system)
            case "${2:-}" in
                check)
                    f='check'
                    shift 2
                    ;;
                info)
                    f='sys_info'
                    shift 2
                    ;;
                log)
                    f='view_latest_tmp_log_file'
                    shift 2
                    ;;
                path)
                    koopa::print "$PATH"
                    return 0
                    ;;
                prefix)
                    case "${3:-}" in
                        '')
                            f="$2"
                            shift 2
                            ;;
                        koopa)
                            f="$2"
                            shift 3
                            ;;
                        *)
                            f="${3}_${2}"
                            if koopa::is_function "koopa::${f//-/_}"
                            then
                                shift 3
                            else
                                koopa::invalid_arg "$*"
                            fi
                            ;;
                    esac
                    ;;
                pull)
                    f='sys_git_pull'
                    shift 2
                    ;;
                homebrew-cask-version)
                    f='get_homebrew_cask_version'
                    shift 2
                    ;;
                macos-app-version)
                    f='get_macos_app_version'
                    shift 2
                    ;;
                version)
                    f='get_version'
                    shift 2
                    ;;
                which)
                    f='which_realpath'
                    shift 2
                    ;;
                brew-dump-brewfile | \
                brew-outdated | \
                delete-cache | \
                disable-passwordless-sudo | \
                enable-passwordless-sudo | \
                fix-zsh-permissions | \
                host-id | \
                os-string | \
                roff | \
                set-permissions | \
                variable | \
                variables)
                    f="$2"
                    shift 2
                    ;;
                *)
                    koopa::invalid_arg "$*"
                    ;;
            esac
            ;;
        test)
            f="$1"
            shift 1
            ;;
        # Soft deprecated args {{{2
        # ----------------------------------------------------------------------
        check | \
        check-system)
            f='check_system'
            shift 1
            ;;
        home)
            f='prefix'
            shift 1
            ;;
        info)
            f='sys_info'
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
