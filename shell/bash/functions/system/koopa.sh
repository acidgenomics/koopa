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
            ;;
        info)
            f='sys_info'
            ;;
        install)
            shift 1
            case "$1" in
                dotfiles)
                    f='install_dotfiles'
                    ;;
                mike)
                    f='install_mike'
                    ;;
                py-koopa)
                    f='install_py_koopa'
                    ;;
                r-koopa)
                    f='install_r_koopa'
                    ;;
                # Defunct args.
                python)
                    koopa::defunct 'Use "py-koopa" instead of "python".'
                    ;;
                r)
                    koopa::defunct 'Use "r-koopa" instead of "r".'
                    ;;
            esac
            ;;
        system)
            shift 1
            case "$1" in
                log)
                    f='view-latest-tmp-log-file'
                    ;;
                pull)
                    f='sys-git-pull'
                    ;;
                os-string | \
                variables)
                    f="$1"
                    ;;
            esac
            ;;
        update)
            shift 1
            case "$1" in
                r-config)
                    f='update-r-config'
                    ;;
            esac
            ;;
        which)
            f='which_realpath'
            ;;



        check)
            f='check_system'
            ;;
        delete-cache | \
        header | \
        list | \
        prefix | \
        test | \
        uninstall | \
        version)
            f="$1"
            ;;
        # Supported, but hidden from user {{{2
        # ----------------------------------------------------------------------
        app-prefix | \
        cellar-prefix | \
        conda-prefix | \
        config-prefix | \
        fix-zsh-permissions | \
        get-homebrew-cask-version | \
        get-macos-app-version | \
        get-version | \
        host-id | \
        make-prefix | \
        roff | \
        set-permissions | \
        variable)
            f="$1"
            ;;
        # Defunct args / error catching {{{2
        # ----------------------------------------------------------------------
        help)
            koopa::defunct 'koopa --help'
            ;;
        home)
            koopa::defunct 'koopa prefix'
            ;;
        os-string)
            koopa::defunct 'koopa system os-string'
            ;;
        update-r-config)
            koopa::defunct 'koopa update r-config'
            ;;
        r-home)
            koopa::defunct 'koopa prefix r'
            ;;
        upgrade)
            koopa::defunct 'koopa update'
            ;;
        variables)
            koopa::defunct 'koopa system variables'
            ;;
        which-realpath)
            koopa::defunct 'koopa which'
            ;;
        *)
            koopa::stop "Unsupported argument: '${*}'."
            ;;
    esac
    fun="koopa::${f//-/_}"
    koopa::assert_is_function "$fun"
    shift 1
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
