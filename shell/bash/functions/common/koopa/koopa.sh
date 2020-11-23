#!/usr/bin/env bash

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
    # @note Updated 2020-11-23.
    # """
    local f fun os_id
    koopa::assert_has_args_eq "$#" 1
    f="${1:?}"
    f="${f//-/_}"
    os_id="$(koopa::os_id)"
    if koopa::is_function "koopa::${os_id}_${f}"
    then
        fun="koopa::${os_id}_${f}"
    elif koopa::is_linux
    then
        if koopa::is_rhel_like && \
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
        else
            fun="koopa::linux_${f}"
        fi
    else
        fun="koopa::${f}"
    fi
    if ! koopa::is_function "$fun"
    then
        koopa::stop "No script available for '${*}' (${fun})."
    fi
    koopa::print "$fun"
    return 0
}

koopa::koopa() { # {{{1
    # """
    # Main koopa function, corresponding to 'koopa' binary.
    # @note Updated 2020-11-18.
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
        app | \
        check-system | \
        header | \
        install | \
        list | \
        test | \
        uninstall | \
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
