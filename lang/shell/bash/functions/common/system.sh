#!/usr/bin/env bash

koopa::help() { # {{{1
    # """
    # Show usage via '--help' flag.
    # @note Updated 2021-10-25.
    # """
    local app arg args first_arg last_arg man_file prefix script_name
    [[ "$#" -eq 0 ]] && return 0
    [[ "${1:-}" == '' ]] && return 0
    first_arg="${1:?}"
    last_arg="${!#}"
    args=("$first_arg" "$last_arg")
    for arg in "${args[@]}"
    do
        case "$arg" in
            '--help' | \
            '-h')
                declare -A app=(
                    [head]="$(koopa::locate_head)"
                    [man]="$(koopa::locate_man)"
                )
                file="$(koopa::realpath "$0")"
                script_name="$(koopa::basename "$file")"
                prefix="$(koopa::parent_dir --num=2 "$file")"
                man_file="${prefix}/man/man1/${script_name}.1"
                if [[ -s "$man_file" ]]
                then
                    "${app[head]}" -n 10 "$man_file" \
                        | koopa::str_detect_fixed - '.TH ' \
                        || koopa::stop "Invalid documentation at '${man_file}'."
                else
                    koopa::stop "No documentation for '${script_name}'."
                fi
                "${app[man]}" "$man_file"
                exit 0
                ;;
        esac
    done
    return 0
}

koopa::info_box() { # {{{1
    # """
    # Configuration information box.
    # @note Updated 2021-03-30.
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

koopa::pager() { # {{{1
    # """
    # Run less with support for colors (escape characters).
    # @note Updated 2021-08-31.
    #
    # Detail on handling escape sequences:
    # https://major.io/2013/05/21/
    #     handling-terminal-color-escape-sequences-in-less/
    # """
    local args
    koopa::assert_has_args "$#"
    koopa::assert_is_installed 'less'
    args=("$@")
    koopa::assert_is_file "${args[-1]}"
    less -R "${args[@]}"
    return 0
}

koopa::roff() { # {{{1
    # """
    # Convert roff markdown files to ronn man pages.
    # @note Updated 2021-10-22.
    # """
    local koopa_prefix
    koopa::assert_is_installed 'ronn'
    koopa_prefix="$(koopa::koopa_prefix)"
    (
        koopa::cd "${koopa_prefix}/man"
        ronn --roff ./*.ronn
        koopa::mv --target-directory='man1' ./*.1
    )
    return 0
}

koopa::run_if_installed() { # {{{1
    # """
    # Run program(s) if installed.
    # @note Updated 2020-06-30.
    # """
    koopa::assert_has_args "$#"
    for arg in "$@"
    do
        if ! koopa::is_installed "$arg"
        then
            koopa::alert_note "Skipping '${arg}'."
            continue
        fi
        local exe
        exe="$(koopa::which_realpath "$arg")"
        "$exe"
    done
    return 0
}

koopa::switch_to_develop() {  # {{{1
    # """
    # Switch koopa install to development version.
    # @note Updated 2021-11-03.
    # """
    local app dict
    koopa::assert_has_no_args "$#"
    declare -A app=(
        [git]="$(koopa::locate_git)"
    )
    declare -A dict=(
        [branch]='develop'
        [origin]='origin'
        [prefix]="$(koopa::koopa_prefix)"
    )
    koopa::h1 "Switching koopa at '${dict[prefix]}' to '${dict[branch]}'."
    "${app[git]}" checkout \
        -B "${dict[branch]}" \
        "${dict[origin]}/${dict[branch]}"
    koopa::sys_set_permissions --recursive "${dict[prefix]}"
    koopa::fix_zsh_permissions
    return 0
}

koopa::sys_chgrp() { # {{{1
    # """
    # chgrp with dynamic sudo handling.
    # @note Updated 2021-09-20.
    # """
    local chgrp group
    koopa::assert_has_args "$#"
    group="$(koopa::sys_group)"
    chgrp=('koopa::chgrp')
    if koopa::is_shared_install
    then
        chgrp+=('--sudo')
    fi
    "${chgrp[@]}" "$group" "$@"
    return 0
}

koopa::sys_chmod() { # {{{1
    # """
    # chmod with dynamic sudo handling.
    # @note Updated 2021-09-20.
    # """
    local chmod
    koopa::assert_has_args "$#"
    chmod=('koopa::chmod')
    if koopa::is_shared_install
    then
        chmod+=('--sudo')
    fi
    "${chmod[@]}" "$@"
    return 0
}

koopa::sys_chown() { # {{{1
    # """
    # chown with dynamic sudo handling.
    # @note Updated 2021-09-20.
    # """
    local chown
    koopa::assert_has_args "$#"
    chown=('koopa::chown')
    if koopa::is_shared_install
    then
        chown+=('--sudo')
    fi
    "${chown[@]}" "$@"
    return 0
}

koopa::sys_cp() { # {{{1
    # """
    # Koopa copy.
    # @note Updated 2021-09-20.
    # """
    local cp
    koopa::assert_has_args "$#"
    cp=('koopa::cp')
    if koopa::is_shared_install
    then
        cp+=('--sudo')
    fi
    "${cp[@]}" "$@"
    return 0
}

koopa::sys_group() { # {{{1
    # """
    # Return the appropriate group to use with koopa installation.
    # @note Updated 2020-07-04.
    #
    # Returns current user for local install.
    # Dynamically returns the admin group for shared install.
    #
    # Admin group priority: admin (macOS), sudo (Debian), wheel (Fedora).
    # """
    local group
    koopa::assert_has_no_args "$#"
    if koopa::is_shared_install
    then
        group="$(koopa::admin_group)"
    else
        group="$(koopa::group)"
    fi
    koopa::print "$group"
    return 0
}

koopa::sys_ln() { # {{{1
    # """
    # Create a symlink quietly.
    # @note Updated 2021-09-20.
    #
    # Don't need to set 'g+rw' for symbolic link here.
    # Symlink permissions are ignored on most systems, including Linux.
    #
    # On macOS, you can override using BSD ln:
    # > /bin/ln -h g+rw <file>
    # """
    local ln source target
    koopa::assert_has_args_eq "$#" 2
    source="${1:?}"
    target="${2:?}"
    ln=('koopa::ln')
    if koopa::is_shared_install
    then
        ln+=('--sudo')
    fi
    "${ln[@]}" "$source" "$target"
    koopa::sys_set_permissions --no-dereference "$target"
    return 0
}

koopa::sys_mkdir() { # {{{1
    # """
    # mkdir with dynamic sudo handling.
    # @note Updated 2021-09-20.
    # """
    local mkdir
    koopa::assert_has_args "$#"
    mkdir=('koopa::mkdir')
    if koopa::is_shared_install
    then
        mkdir+=('--sudo')
    fi
    "${mkdir[@]}" "$@"
    koopa::sys_set_permissions "$@"
    return 0
}

koopa::sys_mv() { # {{{1
    # """
    # Move a file or directory.
    # @note Updated 2021-09-20.
    # """
    local mv
    koopa::assert_has_args "$#"
    mv=('koopa::mv')
    if koopa::is_shared_install
    then
        mv+=('--sudo')
    fi
    "${mv[@]}" "$@"
    return 0
}

koopa::sys_rm() { # {{{1
    # """
    # Remove files/directories quietly.
    # @note Updated 2021-09-20.
    # """
    local rm
    koopa::assert_has_args "$#"
    rm=('koopa::rm')
    if koopa::is_shared_install
    then
        rm+=('--sudo')
    fi
    "${rm[@]}" "$@"
    return 0
}

koopa::sys_set_permissions() { # {{{1
    # """
    # Set permissions on target prefix(es).
    # @note Updated 2021-10-05.
    # """
    koopa::assert_has_args "$#"
    local arg chmod chown dict group pos user
    declare -A dict=(
        [dereference]=1
        [recursive]=0
        [user]=0
    )
    pos=()
    while (("$#"))
    do
        case "$1" in
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
            '-R' | \
            '-r')
                dict[recursive]=0
                shift 1
                ;;
            '--user' | \
            '-u')
                dict[user]=1
                shift 1
                ;;
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
    case "${dict[user]}" in
        '0')
            chmod=('koopa::sys_chmod')
            chown=('koopa::sys_chown')
            group="$(koopa::sys_group)"
            user="$(koopa::sys_user)"
            ;;
        '1')
            chmod=('koopa::chmod')
            chown=('koopa::chown')
            group="$(koopa::group)"
            user="$(koopa::user)"
            ;;
    esac
    chown+=('--no-dereference')
    if [[ "${dict[recursive]}" -eq 1 ]]
    then
        chmod+=('--recursive')
        chown+=('--recursive')
    fi
    if koopa::is_shared_install
    then
        chmod+=('u+rw,g+rw')
    else
        chmod+=('u+rw,g+r,g-w')
    fi
    chown+=("${user}:${group}")
    for arg in "$@"
    do
        if [[ "${dict[dereference]}" -eq 1 ]] && [[ -L "$arg" ]]
        then
            arg="$(koopa::realpath "$arg")"
        fi
        "${chmod[@]}" "$arg"
        "${chown[@]}" "$arg"
    done
    return 0
}

koopa::sys_user() { # {{{1
    # """
    # Set the koopa installation system user.
    # @note Updated 2020-07-06.
    # """
    local user
    koopa::assert_has_no_args "$#"
    if koopa::is_shared_install
    then
        user='root'
    else
        user="$(koopa::user)"
    fi
    koopa::print "$user"
    return 0
}

koopa::variables() { # {{{1
    # """
    # Edit koopa variables.
    # @note Updated 2020-06-30.
    # """
    koopa::assert_has_no_args "$#"
    koopa::assert_is_installed 'vim'
    vim "$(koopa::include_prefix)/variables.txt"
    return 0
}

koopa::warn_if_export() { # {{{1
    # """
    # Warn if variable is exported in current shell session.
    # @note Updated 2020-02-20.
    #
    # Useful for checking against unwanted compiler settings.
    # In particular, useful to check for 'LD_LIBRARY_PATH'.
    # """
    local arg
    koopa::assert_has_args "$#"
    for arg in "$@"
    do
        if koopa::is_export "$arg"
        then
            koopa::warn "'${arg}' is exported."
        fi
    done
    return 0
}
