#!/usr/bin/env bash

koopa::check_system() { # {{{1
    # """
    # Check system.
    # @note Updated 2020-08-12.
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
    # @note Updated 2020-08-12.
    #
    # Useful for private scripts using koopa code outside of package.
    # """
    local file koopa_prefix shell
    koopa::assert_has_args_eq "$#" 1
    shell="${1:?}"
    koopa_prefix="$(koopa::prefix)"
    case "$shell" in
        bash|posix|zsh)
            ;;
        *)
            koopa::stop 'Supported shells: bash, zsh, posix.'
            ;;
    esac
    file="${koopa_prefix}/shell/${shell}/include/header.sh"
    koopa::assert_is_file "$file"
    koopa::print "$file"
    return 0
}

koopa::koopa() { # {{{1
    # """
    # Main koopa function, corresponding to 'koopa' binary.
    # @note Updated 2020-08-12.
    # """
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
        install)
            shift 1
            case "$1" in
                dotfiles)
                    f='install-dotfiles'
                    ;;
                mike)
                    f='install-mike'
                    ;;
                python)
                    f='install-py-koopa'
                    ;;
                r)
                    f='install-r-koopa'
                    ;;
            esac
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
            f='check-system'
            ;;
        log)
            f='view-latest-tmp-log-file'
            ;;
        pull)
            f='sys-git-pull'
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
