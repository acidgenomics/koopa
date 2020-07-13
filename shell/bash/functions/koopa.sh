#!/usr/bin/env bash

koopa::koopa() {
    koopa::assert_has_args "$#"
    # Update corresponding Bash completion file, if necessary.
    case "$1" in
        # Auto-completion {{{2
        # ----------------------------------------------------------------------
        --version|-V)
            f='version'
            ;;
        info)
            f='sys_info'
            ;;
        check-system | \
        header | \
        install-dotfiles | \
        list | \
        prefix | \
        test | \
        uninstall | \
        update | \
        version)
            f="$1"
            ;;
        # Supported, but hidden from user {{{2
        # ----------------------------------------------------------------------
        check)
            f='check_system'
            ;;
        log)
            f='view_latest_tmp_log_file'
            ;;
        pull)
            f='sys_git_pull'
            ;;
        app-prefix | \
        cellar-prefix | \
        conda-prefix | \
        config-prefix | \
        get-homebrew-cask-version | \
        get-macos-app-version | \
        get-version | \
        host-id | \
        install-mike | \
        list-internal-functions | \
        make-prefix | \
        os-string | \
        set-permissions | \
        variable | \
        variables | \
        which-realpath)
            f="$1"
            ;;
        # Deprecated args / error catching {{{2
        # ----------------------------------------------------------------------
        help)
            koopa::defunct 'koopa --help'
            ;;
        home)
            koopa::defunct 'koopa prefix'
            ;;
        update-r-config)
            koopa::defunct 'update-r-config (without koopa prefix)'
            ;;
        r-home)
            koopa::defunct 'koopa which-realpath R'
            ;;
        upgrade)
            koopa::defunct 'koopa update'
            ;;
        *)
            koopa::invalid_arg "$1"
            ;;
    esac
    fun="koopa::${f//-/_}"
    koopa::assert_is_function "$fun"
    shift 1
    "$fun" "$@"
    return 0
}

