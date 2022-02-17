#!/usr/bin/env bash

koopa::cd() { # {{{1
    # """
    # Change directory quietly.
    # @note Updated 2021-05-26.
    # """
    local prefix
    koopa::assert_has_args_eq "$#" 1
    prefix="${1:?}"
    cd "$prefix" >/dev/null 2>&1 || return 1
    return 0
}

koopa::chgrp() { # {{{1
    # """
    # Hardened version of coreutils chgrp (change user group).
    # @note Updated 2021-10-29.
    # """
    local app chgrp dict pos
    declare -A app=(
        [chgrp]="$(koopa::locate_chgrp)"
    )
    declare -A dict=(
        [sudo]=0
    )
    pos=()
    while (("$#"))
    do
        case "$1" in
            # Flags ------------------------------------------------------------
            '--sudo' | \
            '-S')
                dict[sudo]=1
                shift 1
                ;;
            # Other ------------------------------------------------------------
            '-'*)
                koopa::invalid_arg "$1"
                ;;
            *)
                pos+=("$1")
                shift 1
                ;;
        esac
    done
    [[ "${#pos[@]}" -gt 0 ]] && set -- "${pos[@]}"
    koopa::assert_has_args "$#"
    if [[ "${dict[sudo]}" -eq 1 ]]
    then
        app[sudo]="$(koopa::locate_sudo)"
        chgrp=("${app[sudo]}" "${app[chgrp]}")
    else
        chgrp=("${app[chgrp]}")
    fi
    "${chgrp[@]}" "$@"
    return 0
}

# FIXME Require the user to set '--permissions=0644', etc.
koopa::chmod() { # {{{1
    # """
    # Hardened version of coreutils chmod (change file mode bits).
    # @note Updated 2022-02-17.
    # """
    local app chmod dict pos
    declare -A app=(
        [chmod]="$(koopa::locate_chmod)"
    )
    declare -A dict=(
        [recursive]=0
        [sudo]=0
    )
    pos=()
    while (("$#"))
    do
        case "$1" in
            # Flags ------------------------------------------------------------
            '--recursive' | \
            '-R')
                dict[recursive]=1
                shift 1
                ;;
            '--sudo' | \
            '-S')
                dict[sudo]=1
                shift 1
                ;;
            # Other ------------------------------------------------------------
            '-'*)
                koopa::invalid_arg "$1"
                ;;
            *)
                pos+=("$1")
                shift 1
                ;;
        esac
    done
    [[ "${#pos[@]}" -gt 0 ]] && set -- "${pos[@]}"
    koopa::assert_has_args "$#"
    if [[ "${dict[sudo]}" -eq 1 ]]
    then
        app[sudo]="$(koopa::locate_sudo)"
        chmod=("${app[sudo]}" "${app[chmod]}")
    else
        chmod=("${app[chmod]}")
    fi
    if [[ "${dict[recursive]}" -eq 1 ]]
    then
        chmod+=('-R')
    fi
    "${chmod[@]}" "$@"
    return 0
}

koopa::chown() { # {{{1
    # """
    # Hardened version of coreutils chown (change ownership).
    # @note Updated 2021-10-29.
    # """
    local app chown dict pos
    declare -A app=(
        [chown]="$(koopa::locate_chown)"
    )
    declare -A dict=(
        [dereference]=1
        [recursive]=0
        [sudo]=0
    )
    pos=()
    while (("$#"))
    do
        case "$1" in
            # Flags ------------------------------------------------------------
            '--dereference' | \
            '-H')
                dict[dereference]=1
                shift 1
                ;;
            '--no-dereference' | \
            '-h')
                dict[dereference]=0
                shift 1
                ;;
            '--recursive' | \
            '-R')
                dict[recursive]=1
                shift 1
                ;;
            '--sudo' | \
            '-S')
                dict[sudo]=1
                shift 1
                ;;
            # Other ------------------------------------------------------------
            '-'*)
                koopa::invalid_arg "$1"
                ;;
            *)
                pos+=("$1")
                shift 1
                ;;
        esac
    done
    [[ "${#pos[@]}" -gt 0 ]] && set -- "${pos[@]}"
    koopa::assert_has_args "$#"
    if [[ "${dict[sudo]}" -eq 1 ]]
    then
        app[sudo]="$(koopa::locate_sudo)"
        chown=("${app[sudo]}" "${app[chown]}")
    else
        chown=("${app[chown]}")
    fi
    if [[ "${dict[recursive]}" -eq 1 ]]
    then
        chown+=('-R')
    fi
    if [[ "${dict[dereference]}" -eq 0 ]]
    then
        chown+=('-h')
    fi
    "${chown[@]}" "$@"
    return 0
}

koopa::cp() { # {{{1
    # """
    # Hardened version of coreutils cp (copy).
    # @note Updated 2022-01-19.
    # @note '-t' flag is not directly supported for BSD variant.
    #
    # @seealso
    # - GNU cp man:
    #   https://man7.org/linux/man-pages/man1/cp.1.html
    # - BSD cp man:
    #   https://www.freebsd.org/cgi/man.cgi?cp
    #
    # getopts info:
    # - http://mywiki.wooledge.org/BashFAQ/035#getopts
    # - https://wiki.bash-hackers.org/howto/getopts_tutorial
    # """
    local app cp cp_args dict mkdir pos rm
    declare -A app=(
        [cp]="$(koopa::locate_cp)"
        [mkdir]='koopa::mkdir'
        [rm]='koopa::rm'
    )
    declare -A dict=(
        [sudo]=0
        [symlink]=0
        [target_dir]=''
    )
    pos=()
    while (("$#"))
    do
        case "$1" in
            # Key-value pairs --------------------------------------------------
            '--target-directory='*)
                dict[target_dir]="${1#*=}"
                shift 1
                ;;
            '--target-directory' | \
            '-t')
                dict[target_dir]="${2:?}"
                shift 2
                ;;
            # Flags ------------------------------------------------------------
            '--sudo' | \
            '-S')
                dict[sudo]=1
                shift 1
                ;;
            '--symbolic-link' | \
            '--symlink' | \
            '-s')
                dict[symlink]=1
                shift 1
                ;;
            # Other ------------------------------------------------------------
            '-'*)
                koopa::invalid_arg "$1"
                ;;
            *)
                pos+=("$1")
                shift 1
                ;;
        esac
    done
    [[ "${#pos[@]}" -gt 0 ]] && set -- "${pos[@]}"
    koopa::assert_has_args "$#"
    if [[ "${dict[sudo]}" -eq 1 ]]
    then
        app[sudo]="$(koopa::locate_sudo)"
        cp=("${app[sudo]}" "${app[cp]}")
        mkdir=("${app[mkdir]}" '--sudo')
        rm=("${app[rm]}" '--sudo')
    else
        cp=("${app[cp]}")
        mkdir=("${app[mkdir]}")
        rm=("${app[rm]}")
    fi
    cp_args=('-af')
    [[ "${dict[symlink]}" -eq 1 ]] && cp_args+=('-s')
    cp_args+=("$@")
    if [[ -n "${dict[target_dir]}" ]]
    then
        koopa::assert_is_existing "$@"
        dict[target_dir]="$(koopa::strip_trailing_slash "${dict[target_dir]}")"
        if [[ ! -d "${dict[target_dir]}" ]]
        then
            "${mkdir[@]}" "${dict[target_dir]}"
        fi
        cp_args+=("${dict[target_dir]}")
    else
        koopa::assert_has_args_eq "$#" 2
        dict[source_file]="${1:?}"
        koopa::assert_is_existing "${dict[source_file]}"
        dict[target_file]="${2:?}"
        if [[ -e "${dict[target_file]}" ]]
        then
            "${rm[@]}" "${dict[target_file]}"
        fi
        dict[target_parent]="$(koopa::dirname "${dict[target_file]}")"
        if [[ ! -d "${dict[target_parent]}" ]]
        then
            "${mkdir[@]}" "${dict[target_parent]}"
        fi
    fi
    "${cp[@]}" "${cp_args[@]}"
    return 0
}

koopa::df() { # {{{1
    # """
    # Human friendly version of GNU df.
    # @note Updated 2021-10-29.
    # """
    local app
    declare -A app=(
        [df]="$(koopa::locate_df)"
    )
    "${app[df]}" \
        --portability \
        --print-type \
        --si \
        "$@"
    return 0
}

koopa::init_dir() { # {{{1
    # """
    # Initialize (create) a directory and return the real path on disk.
    # @note Updated 2021-11-04.
    # """
    local dict mkdir pos
    declare -A dict=(
        [sudo]=0
    )
    pos=()
    while (("$#"))
    do
        case "$1" in
            # Flags ------------------------------------------------------------
            '--sudo' | \
            '-S')
                dict[sudo]=1
                shift 1
                ;;
            # Other ------------------------------------------------------------
            '-'*)
                koopa::invalid_arg "$1"
                ;;
            *)
                pos+=("$1")
                shift 1
                ;;
        esac
    done
    [[ "${#pos[@]}" -gt 0 ]] && set -- "${pos[@]}"
    koopa::assert_has_args_eq "$#" 1
    dict[dir]="${1:?}"
    if koopa::str_detect_regex \
        --string="${dict[dir]}" \
        --pattern='^~'
    then
        dict[dir]="$(koopa::sub '^~' "${HOME:?}" "${dict[dir]}")"
    fi
    mkdir=('koopa::mkdir')
    [[ "${dict[sudo]}" -eq 1 ]] && mkdir+=('--sudo')
    if [[ ! -d "${dict[dir]}" ]]
    then
        "${mkdir[@]}" "${dict[dir]}"
    fi
    dict[realdir]="$(koopa::realpath "${dict[dir]}")"
    koopa::print "${dict[realdir]}"
    return 0
}

koopa::ln() { # {{{1
    # """
    # Hardened version of coreutils ln (symbolic link generator).
    # @note Updated 2021-10-29.
    # @note '-t' flag is not directly supported for BSD variant.
    # """
    local app dict ln ln_args mkdir pos rm
    declare -A app=(
        [ln]="$(koopa::locate_ln)"
        [mkdir]='koopa::mkdir'
        [rm]='koopa::rm'
    )
    declare -A dict=(
        [sudo]=0
        [target_dir]=''
    )
    pos=()
    while (("$#"))
    do
        case "$1" in
            # Key-value pairs --------------------------------------------------
            '--target-directory='*)
                dict[target_dir]="${1#*=}"
                shift 1
                ;;
            '--target-directory' | \
            '-t')
                dict[target_dir]="${2:?}"
                shift 2
                ;;
            # Flags ------------------------------------------------------------
            '--sudo' | \
            '-S')
                dict[sudo]=1
                shift 1
                ;;
            # Other ------------------------------------------------------------
            '-'*)
                koopa::invalid_arg "$1"
                ;;
            *)
                pos+=("$1")
                shift 1
                ;;
        esac
    done
    [[ "${#pos[@]}" -gt 0 ]] && set -- "${pos[@]}"
    koopa::assert_has_args "$#"
    if [[ "${dict[sudo]}" -eq 1 ]]
    then
        app[sudo]="$(koopa::locate_sudo)"
        ln=("${app[sudo]}" "${app[ln]}")
        mkdir=("${app[mkdir]}" '--sudo')
        rm=("${app[rm]}" '--sudo')
    else
        ln=("${app[ln]}")
        mkdir=("${app[mkdir]}")
        rm=("${app[rm]}")
    fi
    ln_args=('-fns')
    ln_args+=("$@")
    if [[ -n "${dict[target_dir]}" ]]
    then
        koopa::assert_is_existing "$@"
        dict[target_dir]="$(koopa::strip_trailing_slash "${dict[target_dir]}")"
        if [[ ! -d "${dict[target_dir]}" ]]
        then
            "${mkdir[@]}" "${dict[target_dir]}"
        fi
        ln_args+=("${dict[target_dir]}")
    else
        koopa::assert_has_args_eq "$#" 2
        dict[source_file]="${1:?}"
        koopa::assert_is_existing "${dict[source_file]}"
        dict[target_file]="${2:?}"
        if [[ -e "${dict[target_file]}" ]]
        then
            "${rm[@]}" "${dict[target_file]}"
        fi
        dict[target_parent]="$(koopa::dirname "${dict[target_file]}")"
        if [[ ! -d "${dict[target_parent]}" ]]
        then
            "${mkdir[@]}" "${dict[target_parent]}"
        fi
    fi
    "${ln[@]}" "${ln_args[@]}"
    return 0
}

koopa::mkdir() { # {{{1
    # """
    # Create directories with parents automatically.
    # @note Updated 2021-10-29.
    # """
    local app dict mkdir mkdir_args pos
    declare -A app=(
        [mkdir]="$(koopa::locate_mkdir)"
    )
    declare -A dict=(
        [sudo]=0
    )
    pos=()
    while (("$#"))
    do
        case "$1" in
            # Flags ------------------------------------------------------------
            '--sudo' | \
            '-S')
                dict[sudo]=1
                shift 1
                ;;
            # Other ------------------------------------------------------------
            '-'*)
                koopa::invalid_arg "$1"
                ;;
            *)
                pos+=("$1")
                shift 1
                ;;
        esac
    done
    [[ "${#pos[@]}" -gt 0 ]] && set -- "${pos[@]}"
    koopa::assert_has_args "$#"
    mkdir_args=('-p')
    if [[ "${dict[sudo]}" -eq 1 ]]
    then
        app[sudo]="$(koopa::locate_sudo)"
        mkdir=("${app[sudo]}" "${app[mkdir]}")
    else
        mkdir=("${app[mkdir]}")
    fi
    "${mkdir[@]}" "${mkdir_args[@]}" "$@"
    return 0
}

koopa::mv() { # {{{1
    # """
    # Move a file or directory with GNU mv.
    # @note Updated 2021-10-29.
    # @note '-t' flag is not supported for BSD variant.
    #
    # This function works on 1 file or directory at a time.
    # It ensures that the target parent directory exists automatically.
    #
    # Useful GNU mv args, for reference (non-POSIX):
    # * '--no-target-directory'
    # * '--strip-trailing-slashes'
    # """
    local app dict mkdir mv mv_args pos rm
    declare -A app=(
        [mkdir]='koopa::mkdir'
        [mv]="$(koopa::locate_mv)"
        [rm]='koopa::rm'
    )
    declare -A dict=(
        [sudo]=0
        [target_dir]=''
    )
    pos=()
    while (("$#"))
    do
        case "$1" in
            # Key-value pairs --------------------------------------------------
            '--target-directory='*)
                dict[target_dir]="${1#*=}"
                shift 1
                ;;
            '--target-directory' | \
            '-t')
                dict[target_dir]="${2:?}"
                shift 2
                ;;
            # Flags ------------------------------------------------------------
            '--sudo' | \
            '-S')
                dict[sudo]=1
                shift 1
                ;;
            # Other ------------------------------------------------------------
            '-'*)
                koopa::invalid_arg "$1"
                ;;
            *)
                pos+=("$1")
                shift 1
                ;;
        esac
    done
    [[ "${#pos[@]}" -gt 0 ]] && set -- "${pos[@]}"
    koopa::assert_has_args "$#"
    if [[ "${dict[sudo]}" -eq 1 ]]
    then
        app[sudo]="$(koopa::locate_sudo)"
        mkdir=("${app[mkdir]}" '--sudo')
        mv=("${app[sudo]}" "${app[mv]}")
        rm=("${app[rm]}" '--sudo')
    else
        mkdir=("${app[mkdir]}")
        mv=("${app[mv]}")
        rm=("${app[rm]}")
    fi
    mv_args=('-f')
    mv_args+=("$@")
    if [[ -n "${dict[target_dir]}" ]]
    then
        koopa::assert_is_existing "$@"
        dict[target_dir]="$(koopa::strip_trailing_slash "${dict[target_dir]}")"
        if [[ ! -d "${dict[target_dir]}" ]]
        then
            "${mkdir[@]}" "${dict[target_dir]}"
        fi
        mv_args+=("${dict[target_dir]}")
    else
        koopa::assert_has_args_eq "$#" 2
        dict[source_file]="$(koopa::strip_trailing_slash "${1:?}")"
        koopa::assert_is_existing "${dict[source_file]}"
        dict[target_file]="$(koopa::strip_trailing_slash "${2:?}")"
        if [[ -e "${dict[target_file]}" ]]
        then
            "${rm[@]}" "${dict[target_file]}"
        fi
        dict[target_parent]="$(koopa::dirname "${dict[target_file]}")"
        if [[ ! -d "${dict[target_parent]}" ]]
        then
            "${mkdir[@]}" "${dict[target_parent]}"
        fi
    fi
    "${mv[@]}" "${mv_args[@]}"
    return 0
}

koopa::parent_dir() { # {{{1
    # """
    # Get the parent directory path.
    # @note Updated 2021-09-21.
    #
    # This requires file to exist and resolves symlinks.
    # """
    local app dict file parent pos
    declare -A app=(
        [sed]="$(koopa::locate_sed)"
    )
    declare -A dict=(
        [cd_tail]=''
        [n]=1
    )
    pos=()
    while (("$#"))
    do
        case "$1" in
            # Key-value pairs --------------------------------------------------
            '--num='*)
                dict[n]="${1#*=}"
                shift 1
                ;;
            '--num' | \
            '-n')
                dict[n]="${2:?}"
                shift 2
                ;;
            # Other ------------------------------------------------------------
            '-'*)
                koopa::invalid_arg "$1"
                ;;
            *)
                pos+=("$1")
                shift 1
                ;;
        esac
    done
    [[ "${#pos[@]}" -gt 0 ]] && set -- "${pos[@]}"
    koopa::assert_has_args "$#"
    [[ "${dict[n]}" -ge 1 ]] || dict[n]=1
    if [[ "${dict[n]}" -ge 2 ]]
    then
        dict[n]="$((dict[n]-1))"
        dict[cd_tail]="$( \
            printf "%${dict[n]}s" \
            | "${app[sed]}" 's| |/..|g' \
        )"
    fi
    for file in "$@"
    do
        [[ -e "$file" ]] || return 1
        parent="$(koopa::dirname "$file")"
        parent="${parent}${dict[cd_tail]}"
        parent="$(koopa::cd "$parent" && pwd -P)"
        koopa::print "$parent"
    done
    return 0
}

koopa::relink() { # {{{1
    # """
    # Re-create a symbolic link dynamically, if broken.
    # @note Updated 2020-10-29.
    # """
    local app dict ln pos rm sudo
    declare -A app=(
        [ln]='koopa::ln'
        [rm]='koopa::rm'
    )
    declare -A dict=(
        [sudo]=0
    )
    pos=()
    while (("$#"))
    do
        case "$1" in
            # Flags ------------------------------------------------------------
            '--sudo' | \
            '-S')
                dict[sudo]=1
                shift 1
                ;;
            # Other ------------------------------------------------------------
            '-'*)
                koopa::invalid_arg "$1"
                ;;
            *)
                pos+=("$1")
                shift 1
                ;;
        esac
    done
    [[ "${#pos[@]}" -gt 0 ]] && set -- "${pos[@]}"
    koopa::assert_has_args_eq "$#" 2
    ln=('koopa::ln')
    rm=('koopa::rm')
    if [[ "${dict[sudo]}" -eq 1 ]]
    then
        ln+=('--sudo')
        rm+=('--sudo')
    fi
    dict[source_file]="${1:?}"
    dict[dest_file]="${2:?}"
    # Keep this check relaxed (i.e. in case dotfiles haven't been cloned).
    [[ -e "${dict[source_file]}" ]] || return 0
    [[ -L "${dict[dest_file]}" ]] && return 0
    "${rm[@]}" "${dict[dest_file]}"
    "${ln[@]}" "${dict[source_file]}" "${dict[dest_file]}"
    return 0
}

koopa::rm() { # {{{1
    # """
    # Remove files/directories quietly with GNU rm.
    # @note Updated 2021-09-21.
    # """
    local app dict pos rm rm_args
    declare -A app=(
        [rm]="$(koopa::locate_rm)"
    )
    declare -A dict=(
        [sudo]=0
    )
    pos=()
    while (("$#"))
    do
        case "$1" in
            # Flags ------------------------------------------------------------
            '--sudo' | \
            '-S')
                dict[sudo]=1
                shift 1
                ;;
            # Other ------------------------------------------------------------
            '-'*)
                koopa::invalid_arg "$1"
                ;;
            *)
                pos+=("$1")
                shift 1
                ;;
        esac
    done
    [[ "${#pos[@]}" -gt 0 ]] && set -- "${pos[@]}"
    koopa::assert_has_args "$#"
    rm_args=('-fr')
    if [[ "${dict[sudo]}" -eq 1 ]]
    then
        app[sudo]="$(koopa::locate_sudo)"
        rm+=("${app[sudo]}" "${app[rm]}")
    else
        rm=("${app[rm]}")
    fi
    "${rm[@]}" "${rm_args[@]}" "$@"
    return 0
}

koopa::touch() { # {{{1
    # """
    # Touch (create) a file on disk.
    # @note Updated 2022-02-16.
    # """
    local app mkdir pos touch
    koopa::assert_has_args "$#"
    declare -A app=(
        [touch]="$(koopa::locate_touch)"
    )
    declare -A dict=(
        [sudo]=0
    )
    pos=()
    while (("$#"))
    do
        case "$1" in
            # Flags ------------------------------------------------------------
            '--sudo' | \
            '-S')
                dict[sudo]=1
                shift 1
                ;;
            # Other ------------------------------------------------------------
            '-'*)
                koopa::invalid_arg "$1"
                ;;
            *)
                pos+=("$1")
                shift 1
                ;;
        esac
    done
    [[ "${#pos[@]}" -gt 0 ]] && set -- "${pos[@]}"
    koopa::assert_has_args "$#"
    mkdir=('koopa::mkdir')
    if [[ "${dict[sudo]}" -eq 1 ]]
    then
        app[sudo]="$(koopa::locate_sudo)"
        mkdir+=('--sudo')
        touch=("${app[sudo]}" "${app[touch]}")
    else
        touch=("${app[touch]}")
    fi
    for file in "$@"
    do
        local dn
        if [[ -e "$file" ]]
        then
            koopa::assert_is_not_dir "$file"
            koopa::assert_is_not_symlink "$file"
        fi
        # Automatically create parent directory, if necessary.
        dn="$(koopa::dirname "$file")"
        if [[ ! -d "$dn" ]] && \
            koopa::str_detect_fixed \
                --string="$dn" \
                --pattern='/'
        then
            "${mkdir[@]}" "$dn"
        fi
        "${touch[@]}" "$file"
    done
    return 0
}

koopa::which() { # {{{1
    # """
    # Locate which program.
    # @note Updated 2021-05-26.
    #
    # Example:
    # koopa::which bash
    # """
    local cmd
    koopa::assert_has_args "$#"
    for cmd in "$@"
    do
        if koopa::is_alias "$cmd"
        then
            unalias "$cmd"
        elif koopa::is_function "$cmd"
        then
            unset -f "$cmd"
        fi
        cmd="$(command -v "$cmd")"
        [[ -x "$cmd" ]] || return 1
        koopa::print "$cmd"
    done
    return 0
}

koopa::which_realpath() { # {{{1
    # """
    # Locate the realpath of a program.
    # @note Updated 2021-06-03.
    #
    # This resolves symlinks automatically.
    # For 'which' style return, use 'koopa::which' instead.
    #
    # @seealso
    # - https://stackoverflow.com/questions/7665
    # - https://unix.stackexchange.com/questions/85249
    # - https://stackoverflow.com/questions/7522712
    # - https://thoughtbot.com/blog/input-output-redirection-in-the-shell
    #
    # @examples
    # koopa::which_realpath bash vim
    # """
    local cmd
    koopa::assert_has_args "$#"
    for cmd in "$@"
    do
        cmd="$(koopa::which "$cmd")"
        [[ -n "$cmd" ]] || return 1
        cmd="$(koopa::realpath "$cmd")"
        [[ -x "$cmd" ]] || return 1
        koopa::print "$cmd"
    done
    return 0
}
