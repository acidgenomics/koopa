#!/usr/bin/env bash

__koopa_get_version_arg() { # {{{1
    # """
    # Return matching version argument for an input program.
    # @note Updated 2022-03-18.
    # """
    local arg name
    koopa_assert_has_args_eq "$#" 1
    name="$(koopa_basename "${1:?}")"
    case "$name" in
        'docker-credential-pass' | \
        'go' | \
        'openssl' | \
        'rstudio-server' | \
        'singularity')
            arg='version'
            ;;
        'lua')
            arg='-v'
            ;;
        'openssh' | \
        'ssh' | \
        'tmux')
            arg='-V'
            ;;
        *)
            arg='--version'
            ;;
    esac
    koopa_print "$arg"
    return 0
}

__koopa_get_version_name() { # {{{1
    # """
    # Match a desired program name to corresponding to dependency to
    # run with a version argument.
    # @note Updated 2022-03-25.
    # """
    local name
    koopa_assert_has_args_eq "$#" 1
    name="$(koopa_basename "${1:?}")"
    case "$name" in
        'aspera-connect')
            name='ascp'
            ;;
        'aws-cli')
            name='aws'
            ;;
        'azure-cli')
            name='az'
            ;;
        'bcbio-nextgen')
            name='bcbio_nextgen.py'
            ;;
        'binutils')
            # Checking against 'ld' doesn't work on macOS with Homebrew.
            name='dlltool'
            ;;
        'coreutils')
            name='env'
            ;;
        'du-dust')
            name='dust'
            ;;
        'fd-find')
            name='fd'
            ;;
        'findutils')
            name='find'
            ;;
        'gdal')
            name='gdal-config'
            ;;
        'geos')
            name='geos-config'
            ;;
        'gnupg')
            name='gpg'
            ;;
        'google-cloud-sdk')
            name='gcloud'
            ;;
        'gsl')
            name='gsl-config'
            ;;
        'homebrew')
            name='brew'
            ;;
        'icu')
            name='icu-config'
            ;;
        'llvm')
            name='llvm-config'
            ;;
        'man-db')
            name='man'
            ;;
        'ncurses')
            name='ncurses6-config'
            ;;
        'neovim')
            name='nvim'
            ;;
        'openssh')
            name='ssh'
            ;;
        'password-store')
            name='pass'
            ;;
        'pcre2')
            name='pcre2-config'
            ;;
        'pip')
            name='pip3'
            ;;
        'python')
            name='python3'
            ;;
        'ranger-fm')
            name='ranger'
            ;;
        'ripgrep')
            name='rg'
            ;;
        'ripgrep-all')
            name='rga'
            ;;
        'rust')
            name='rustc'
            ;;
        'sqlite')
            name='sqlite3'
            ;;
        'subversion')
            name='svn'
            ;;
        'tealdeer')
            name='tldr'
            ;;
        'texinfo')
            # TeX Live install can mask this on macOS.
            name='texi2any'
            ;;
        'the-silver-searcher')
            name='ag'
            ;;
    esac
    koopa_print "$name"
    return 0
}

koopa_extract_version() { # {{{1
    # """
    # Extract version number.
    # @note Updated 2022-02-27.
    #
    # @examples
    # > koopa_extract_version "$(bash --version)"
    # # 5.1.16
    # """
    local app arg dict
    declare -A app=(
        [head]="$(koopa_locate_head)"
    )
    declare -A dict=(
        [pattern]="$(koopa_version_pattern)"
    )
    if [[ "$#" -eq 0 ]]
    then
        args=("$(</dev/stdin)")
    else
        args=("$@")
    fi
    for arg in "${args[@]}"
    do
        local str
        str="$( \
            koopa_grep \
                --only-matching \
                --pattern="${dict[pattern]}" \
                --regex \
                --string="$arg" \
            | "${app[head]}" -n 1 \
        )"
        [[ -n "$str" ]] || return 1
        koopa_print "$str"
    done
    return 0
}

koopa_get_version() { # {{{1
    # """
    # Get the version of an installed program.
    # @note Updated 2022-04-15.
    #
    # @examples
    # > koopa system version 'R' 'conda' 'coreutils' 'python' 'salmon' 'zsh'
    # """
    local cmd
    koopa_assert_has_args "$#"
    for cmd in "$@"
    do
        local dict
        declare -A dict
        dict[cmd]="$cmd"
        dict[bn1]="$(koopa_basename "${dict[cmd]}")"
        dict[bn]="${dict[bn1]}"
        dict[bn2]="$(__koopa_get_version_name "${dict[bn1]}")"
        if [[ "${dict[bn1]}" != "${dict[bn2]}" ]]
        then
            dict[bn]="${dict[bn2]}"
            dict[cmd]="${dict[bn]}"
        fi
        dict[bn_snake]="$(koopa_snake_case_simple "${dict[bn]}")"
        dict[version_arg]="$(__koopa_get_version_arg "${dict[bn]}")"
        dict[locate_fun]="koopa_locate_${dict[bn_snake]}"
        dict[version_fun]="koopa_${dict[bn_snake]}_version"
        if [[ -x "${dict[cmd]}" ]] && \
            [[ ! -d "${dict[cmd]}" ]] && \
            koopa_is_installed "${dict[cmd]}"
        then
            dict[cmd]="$(koopa_realpath "${dict[cmd]}")"
        fi
        if koopa_is_function "${dict[version_fun]}"
        then
            if [[ -x "${dict[cmd]}" ]] && \
                [[ ! -d "${dict[cmd]}" ]] && \
                koopa_is_installed "${dict[cmd]}"
            then
                dict[str]="$("${dict[version_fun]}" "${dict[cmd]}")"
            else
                dict[str]="$("${dict[version_fun]}")"
            fi
            [[ -n "${dict[str]}" ]] || return 1
            koopa_print "${dict[str]}"
            continue
        fi
        if ! { \
            [[ -x "${dict[cmd]}" ]] && \
            [[ ! -d "${dict[cmd]}" ]] && \
            koopa_is_installed "${dict[cmd]}"; \
        }
        then
            if koopa_is_function "${dict[locate_fun]}"
            then
                dict[cmd]="$("${dict[locate_fun]}")"
            else
                dict[cmd]="$(koopa_which_realpath "${dict[cmd]}")"
            fi
        fi
        koopa_is_installed "${dict[cmd]}" || return 1
        [[ -x "${dict[cmd]}" ]] || return 1
        dict[str]="$("${dict[cmd]}" "${dict[version_arg]}" 2>&1 || true)"
        [[ -n "${dict[str]}" ]] || return 1
        dict[str]="$(koopa_extract_version "${dict[str]}")"
        [[ -n "${dict[str]}" ]] || return 1
        koopa_print "${dict[str]}"
    done
    return 0
}

koopa_get_version_from_pkg_config() { # {{{1
    # """
    # Get a library version via pkg-config.
    # @note Updated 2022-02-27.
    # """
    local app pkg str
    koopa_assert_has_args_eq "$#" 1
    pkg="${1:?}"
    declare -A app=(
        [pkg_config]="$(koopa_locate_pkg_config)"
    )
    str="$("${app[pkg_config]}" --modversion "$pkg")"
    [[ -n "$str" ]] || return 1
    koopa_print "$str"
    return 0
}

koopa_sanitize_version() { # {{{1
    # """
    # Sanitize version.
    # @note Updated 2022-04-25.
    #
    # @examples
    # > koopa_sanitize_version '2.7.1p83'
    # # 2.7.1
    # """
    local str
    koopa_assert_has_args "$#"
    for str in "$@"
    do
        koopa_str_detect_regex \
            --string="$str" \
            --pattern='[.0-9]+' \
            || return 1
        str="$( \
            koopa_sub \
                --pattern='^([.0-9]+).*$' \
                --regex \
                --replacement='\1' \
                "$str" \
        )"
        koopa_print "$str"
    done
    return 0
}

koopa_version_pattern() { # {{{1
    # """
    # Version pattern.
    # @note Updated 2022-02-27.
    # """
    koopa_assert_has_no_args "$#"
    koopa_print '[0-9]+\.[0-9]+(\.[0-9]+)?(\.[0-9]+)?([+a-z])?([0-9]+)?'
    return 0
}
