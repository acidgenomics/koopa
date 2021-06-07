#!/usr/bin/env bash

# FIXME Move this to separate file.
koopa::extract_version() { # {{{1
    # """
    # Extract version number.
    # @note Updated 2021-05-24.
    # """
    local arg grep head pattern x
    koopa::assert_has_args "$#"
    grep="$(koopa::locate_grep)"
    head="$(koopa::locate_head)"
    pattern="$(koopa::version_pattern)"
    for arg in "$@"
    do
        x="$( \
            koopa::print "$arg" \
                | "$grep" -Eo "$pattern" \
                | "$head" -n 1 \
        )"
        [[ -n "$x" ]] || return 1
        koopa::print "$x"
    done
    return 0
}

# FIXME Move this.
koopa::get_version() { # {{{1
    # """
    # Get the version of an installed program.
    # @note Updated 2020-07-05.
    # """
    local cmd fun x
    koopa::assert_has_args "$#"
    for cmd in "$@"
    do
        fun="koopa::$(koopa::snake_case_simple "$cmd")_version"
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

# FIXME Move this to separate file...
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
            # > cmd='ld'  # doesn't work on macOS with Homebrew.
            cmd='dlltool'
            ;;
        coreutils)
            cmd='env'
            ;;
        du-dust)
            cmd='dust'
            ;;
        fd-find)
            cmd='fd'
            ;;
        findutils)
            cmd='find'
            ;;
        gdal)
            # Changed from 'gdalinfo' to 'gdal-config' in 3.2.0.
            cmd='gdal-config'
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
        icu)
            cmd='icu-config'
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
            cmd="$(koopa::locate_python)"
            ;;
        ranger-fm)
            cmd='ranger'
            ;;
        ripgrep)
            cmd='rg'
            ;;
        ripgrep-all)
            cmd='rga'
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

# FIXME Move this.
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

# FIXME Move this into a separate file.
koopa::variable() { # {{{1
    # """
    # Return a variable stored 'variables.txt' include file.
    # @note Updated 2021-05-25.
    #
    # This approach handles inline comments.
    # """
    local cut file grep head include_prefix key value
    cut="$(koopa::locate_cut)"
    grep="$(koopa::locate_grep)"
    head="$(koopa::locate_head)"
    key="${1:?}"
    include_prefix="$(koopa::include_prefix)"
    file="${include_prefix}/variables.txt"
    koopa::assert_is_file "$file"
    value="$( \
        "$grep" -Eo "^${key}=\"[^\"]+\"" "$file" \
        || koopa::stop "'${key}' not defined in '${file}'." \
    )"
    value="$( \
        koopa::print "$value" \
            | "$head" -n 1 \
            | "$cut" -d '"' -f 2 \
    )"
    [[ -n "$value" ]] || return 1
    koopa::print "$value"
    return 0
}

# FIXME Move this.
koopa::version() { # {{{1
    # """
    # Koopa version.
    # @note Updated 2020-06-29.
    # """
    koopa::assert_has_no_args "$#"
    koopa::variable 'koopa-version'
    return 0
}

# FIXME Move this.
koopa::version_pattern() { # {{{1
    # """
    # Version pattern.
    # @note Updated 2020-07-14.
    # """
    koopa::assert_has_no_args "$#"
    koopa::print '[0-9]+\.[0-9]+(\.[0-9]+)?(\.[0-9]+)?([a-z])?([0-9]+)?'
    return 0
}
