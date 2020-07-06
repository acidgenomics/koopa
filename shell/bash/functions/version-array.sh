#!/usr/bin/env bash

koopa::extract_version() { # {{{1
    # """
    # Extract version number.
    # @note Updated 2020-07-05.
    # """
    koopa::assert_has_args "$#"
    local arg pattern x
    pattern="$(koopa::version_pattern)"
    for arg in "$@"
    do
        x="$( \
            koopa::print "$arg" \
                | grep -Eo "$pattern" \
                | head -n 1 \
        )"
        [[ -n "$x" ]] || return 1
        koopa::print "$x"
    done
    return 0
}

koopa::get_homebrew_cask_version() { # {{{1
    # """
    # Get Homebrew Cask version.
    # @note Updated 2020-07-05.
    #
    # @examples koopa::get_homebrew_cask_version gpg-suite
    # # 2019.2
    # """
    koopa::assert_has_args "$#"
    koopa::assert_is_installed brew
    local cask x
    for cask in "$@"
    do
        x="$(brew cask info "$cask")"
        x="$(koopa::extract_version "$x")"
        [[ -n "$x" ]] || return 1
        koopa::print "$x"
    done
    return 0
}

koopa::get_macos_app_version() { # {{{1
    # """
    # Extract the version of a macOS application.
    # @note Updated 2020-07-05.
    # """
    koopa::assert_has_args "$#"
    koopa::assert_is_macos
    koopa::assert_is_installed plutil
    local app plist x
    for app in "$@"
    do
        plist="/Applications/${app}.app/Contents/Info.plist"
        if [[ ! -f "$plist" ]]
        then
            koopa::stop "'${app}' is not installed."
        fi
        x="$( \
            plutil -p "$plist" \
                | grep 'CFBundleShortVersionString' \
                | awk -F ' => ' '{print $2}' \
                | tr -d '\"' \
        )"
        [[ -n "$x" ]] || return 1
        koopa::print "$x"
    done
    return 0
}

koopa::get_version() { # {{{1
    # """
    # Get the version of an installed program.
    # @note Updated 2020-07-05.
    # """
    local cmd fun x
    koopa::assert_has_args "$#"
    for cmd in "$@"
    do
        fun="koopa::$(koopa::snake_case "$cmd")_version"
        if koopa::is_function "$fun"
        then
            x="$("$fun")"
        else
            x="$(koopa::return_version "$cmd")"
        fi
        [[ -n "$x" ]] || return 1
        koopa::print "$x"
    done
    return 0
}

# FIXME PARAMETERIZE.
# FIXME USE R HERE INSTEAD OF RSCRIPT.
# FIXME DONT USE RSCRIPT IN FUNCTIONS...
# FIXME SAFE TO MOVE TO BASH, IF NECESSARY.
koopa::r_package_version() { # {{{1
    # """
    # R package version.
    # @note Updated 2020-07-05.
    # """
    koopa::assert_has_args "$#"
    local pkg r rscript x
    r='R'

    rscript"${r}script"
    koopa::assert_is_installed "$r" "$rscript"

    # FIXME REWORK THIS: FLAG SUPPORT?.
    koopa::assert_is_r_package_installed "$pkg" "$rscript"

    for pkg in "$@"
    do
        x="$( \
            "$rscript" \
            -e "cat(as.character(packageVersion(\"${pkg}\")), \"\n\")" \
        )"
        [[ -n "$x" ]] || return 1
        koopa::print "$x"
    done
    return 0
}

koopa::return_version() { # {{{1
    # """
    # Return version (via extraction).
    # @note Updated 2020-06-29.
    # """
    local cmd flag x
    koopa::assert_has_args_le "$#" 2
    cmd="${1:?}"
    flag="${2:-}"
    case "$cmd" in
        aspera-connect)
            cmd='ascp'
            ;;
        aws-cli)
            cmd='aws'
            ;;
        azure-cli)
            cmd='az'
            ;;
        bcbio-nextgen)
            cmd='bcbio_nextgen.py'
            ;;
        binutils)
            cmd='ld'
            ;;
        coreutils)
            cmd='env'
            ;;
        findutils)
            cmd='find'
            ;;
        gdal)
            cmd='gdalinfo'
            ;;
        geos)
            cmd='geos-config'
            ;;
        gnupg)
            cmd='gpg'
            ;;
        google-cloud-sdk)
            cmd='gcloud'
            ;;
        gsl)
            cmd='gsl-config'
            ;;
        homebrew)
            cmd='brew'
            ;;
        ncurses)
            cmd='ncurses6-config'
            ;;
        neovim)
            cmd='nvim'
            ;;
        pip)
            cmd='pip3'
            ;;
        python)
            cmd='python3'
            ;;
        ripgrep)
            cmd='rg'
            ;;
        rust)
            cmd='rustc'
            ;;
        sqlite)
            cmd='sqlite3'
            ;;
        subversion)
            cmd='svn'
            ;;
        texinfo)
            cmd='makeinfo'
            ;;
        the-silver-searcher)
            cmd='ag'
            ;;
    esac
    if [[ -z "${flag:-}" ]]
    then
        case "$cmd" in
            docker-credential-pass)
                flag='version'
                ;;
            go)
                flag='version'
                ;;
            lua)
                flag='-v'
                ;;
            openssl)
                flag='version'
                ;;
            rstudio-server)
                flag='version'
                ;;
            ssh)
                flag='-V'
                ;;
            singularity)
                flag='version'
                ;;
            tmux)
                flag='-V'
                ;;
            *)
                flag='--version'
                ;;
        esac
    fi
    koopa::is_installed "$cmd" || return 1
    x="$("$cmd" "$flag" 2>&1 || true)"
    [[ -n "$x" ]] || return 1
    koopa::extract_version "$x"
    return 0
}

koopa::sanitize_version() { # {{{1
    # """
    # Sanitize version.
    # @note Updated 2020-07-05.
    # """
    koopa::assert_has_args "$#"
    local pattern x
    pattern='[.0-9]+'
    for x in "$@"
    do
        koopa::str_match_regex "$x" "$pattern" || return 1
        x="$(koopa::print "$x" | grep -Eo "$pattern")"
        koopa::print "$x"
    done
    return 0
}
