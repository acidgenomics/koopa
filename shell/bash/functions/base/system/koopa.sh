#!/usr/bin/env bash

koopa::check_system() { # {{{1
    # """
    # Check system.
    # @note Updated 2020-11-11.
    # """
    local koopa_prefix script
    koopa::assert_has_no_args "$#"
    koopa::assert_is_installed Rscript
    koopa_prefix="$(koopa::prefix)"
    export KOOPA_FORCE=1
    set +u
    # shellcheck disable=SC1090
    . "${koopa_prefix}/activate"
    set -u
    script="$(koopa::prefix)/lang/r/include/check-system.R"
    koopa::assert_is_file "$script"
    Rscript --vanilla "$script"
    koopa::check_exports
    koopa::check_disk
    koopa::check_data_disk
    return 0
}

koopa::header() { # {{{1
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

koopa::koopa() { # {{{1
    # """
    # Main koopa function, corresponding to 'koopa' binary.
    # @note Updated 2020-11-12.
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
        info)
            f='sys_info'
            shift 1
            ;;
        install)
            case "${2:-}" in
                *)
                    f="${1}_${2}"
                    if koopa::is_function "koopa::${f//-/_}"
                    then
                        shift 2
                    else
                        koopa::invalid_arg "$*"
                    fi
                    ;;
            esac
            ;;
        system)
            case "${2:-}" in
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
                delete-cache | \
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
        update)
            case "${2:-}" in
                r-config)
                    f="${1}_${2}"
                    shift 2
                    ;;
                *)
                    f="$1"
                    shift 1
                    ;;
            esac
            ;;
        header | \
        list | \
        test | \
        uninstall)
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
            koopa::defunct 'koopa system prefix cellar'
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

koopa::info_box() { # {{{1
    # """
    # Info box.
    # @note Updated 2020-07-04.
    #
    # Using unicode box drawings here.
    # Note that we're truncating lines inside the box to 68 characters.
    # """
    koopa::assert_has_args "$#"
    local array
    array=("$@")
    local barpad
    barpad="$(printf '━%.0s' {1..70})"
    printf '  %s%s%s  \n' '┏' "$barpad" '┓'
    for i in "${array[@]}"
    do
        printf '  ┃ %-68s ┃  \n' "${i::68}"
    done
    printf '  %s%s%s  \n\n' '┗' "$barpad" '┛'
    return 0
}

koopa::install_py_koopa() { # {{{1
    # """
    # Install Python koopa package.
    # @note Updated 2020-08-12.
    # """
    local url
    url='https://github.com/acidgenomics/koopa/archive/python.tar.gz'
    koopa::pip_install "$@" "$url"
    return 0
}

koopa::install_r_koopa() { # {{{1
    # """
    # Install koopa R package.
    # @note Updated 2020-08-12.
    # """
    local script
    koopa::assert_has_no_args "$#"
    koopa::is_installed Rscript || return 0
    script="$(koopa::prefix)/lang/r/include/install.R"
    koopa::assert_is_file "$script"
    Rscript "$script"
    return 0
}

koopa::list() { # {{{1
    # """
    # List exported koopa scripts.
    # @note Updated 2020-08-12.
    # """
    local script
    koopa::assert_has_no_args "$#"
    koopa::assert_is_installed Rscript
    script="$(koopa::prefix)/lang/r/include/list.R"
    koopa::assert_is_file "$script"
    Rscript --vanilla "$script"
    return 0
}

koopa::test() { # {{{1
    # """
    # Run koopa unit tests.
    # @note Updated 2020-08-12.
    # """
    local script
    script="$(koopa::tests_prefix)/tests"
    koopa::assert_is_file "$script"
    "$script" "$@"
    return 0
}
