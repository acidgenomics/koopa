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

koopa::r_package_version() { # {{{1
    # """
    # R package version.
    # @note Updated 2020-07-06.
    # """
    local r rscript vec x
    koopa::assert_has_args "$#"
    r='R'
    rscript="${r}script"
    koopa::assert_is_installed "$r" "$rscript"
    pkgs=("$@")
    koopa::assert_is_r_package_installed "${pkgs[@]}"
    vec="$(koopa::array_to_r_vector "${pkgs[@]}")"
    x="$( \
        "$rscript" -e " \
            cat(vapply( \
                X = ${vec}, \
                FUN = function(x) { \
                    as.character(packageVersion(x)) \
                }, \
                FUN.VALUE = character(1L) \
            ), sep = '\n') \
        " \
    )"
    [[ -n "$x" ]] || return 1
    koopa::print "$x"
    return 0
}

koopa::return_version() { # {{{1
    # """
    # Return version (via extraction).
    # @note Updated 2020-07-14.
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
        openssh)
            cmd='ssh'
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
    # @note Updated 2020-07-14.
    # @examples
    # koopa::sanitize_version '2.7.1p83'
    # ## 2.7.1
    # """
    local pattern x
    koopa::assert_has_args "$#"
    pattern='[.0-9]+'
    for x in "$@"
    do
        koopa::str_match_regex "$x" "$pattern" || return 1
        x="$(koopa::sub '^([.0-9]+).*$' '\1' "$x")"
        koopa::print "$x"
    done
    return 0
}
