#!/usr/bin/env bash

koopa::_koopa_app() { # {{{1
    # """
    # Application commands.
    # @note Updated 2020-12-31.
    # """
    local name
    name="${1:-}"
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
    koopa::_run_function "$name"
    return 0
}

koopa::_koopa_header() { # {{{1
    # """
    # Source script header.
    # @note Updated 2020-09-11.
    #
    # Useful for private scripts using koopa code outside of package.
    # """
    local arg ext file koopa_prefix subdir
    koopa::assert_has_args_eq "$#" 1
    arg="$(koopa::lowercase "${1:?}")"
    koopa_prefix="$(koopa::prefix)"
    case "$arg" in
        bash|posix|zsh)
            subdir='shell'
            ext='sh'
            ;;
        # > python)
        # >     subdir='lang'
        # >     ext='py'
        # >     ;;
        r)
            subdir='lang'
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

koopa::_koopa_install() { # {{{1
    # """
    # Install commands.
    # @note Updated 2020-12-02.
    # """
    local name
    name="${1:-}"
    if [[ -z "$name" ]]
    then
        koopa::stop 'Program name to install is required.'
    fi
    shift 1
    koopa::_run_function "install_${name}" "$@"
    return 0
}

# FIXME SIMPLIFY THE ARGPARSING HERE.
koopa::_koopa_list() { # {{{1
    # """
    # List exported koopa scripts.
    # @note Updated 2020-12-31.
    # """
    local name
    name="${1:-}"
    case "$name" in
        '')
            koopa::list
            ;;
        # FIXME SIMPLIFY THE ARGPARSING HERE.
        app-versions)
            shift 1
            koopa::list_app_versions "$@"
            ;;
        dotfiles)
            shift 1
            koopa::list_dotfiles "$@"
            ;;
        path-priority)
            shift 1
            koopa::list_path_priority "$@"
            ;;
        *)
            koopa::invalid_arg "$*"
            ;;
    esac
    return 0
}

koopa::_koopa_uninstall() { # {{{1
    # """
    # Uninstall commands.
    # @note Updated 2020-11-18.
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

# FIXME NEED TOP_LEVEL SUPPORT FOR LINK HERE.

koopa::koopa() { # {{{1
    # """
    # Main koopa function, corresponding to 'koopa' binary.
    # @note Updated 2020-12-01.
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
        uninstall)
            f="_koopa_${1}"
            shift 1
            ;;
        system)
            case "${2:-}" in
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
        check-system | \
        test | \
        update)
            f="$1"
            shift 1
            ;;
        # Soft deprecated args {{{2
        # ----------------------------------------------------------------------
        check)
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
