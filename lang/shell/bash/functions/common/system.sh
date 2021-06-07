#!/usr/bin/env bash

koopa::help() { # {{{1
    # """
    # Show usage via '--help' flag.
    # @note Updated 2021-06-07.
    # """
    local arg args first_arg last_arg man_file prefix script_name
    [[ "$#" -eq 0 ]] && return 0
    [[ "${1:-}" == "" ]] && return 0
    first_arg="${1:?}"
    last_arg="${!#}"
    args=("$first_arg" "$last_arg")
    for arg in "${args[@]}"
    do
        case "$arg" in
            --help|-h)
                koopa::assert_is_installed 'man'
                file="$(koopa::realpath "$0")"
                script_name="$(koopa::basename "$file")"
                prefix="$(koopa::parent_dir -n 2 "$file")"
                man_file="${prefix}/man/man1/${script_name}.1"
                if [[ -s "$man_file" ]]
                then
                    head -n 10 "$man_file" \
                        | koopa::str_match_regex '^\.TH ' \
                        || koopa::stop "Invalid documentation at '${man_file}'."
                else
                    koopa::stop "No documentation for '${script_name}'."
                fi
                man "$man_file"
                exit 0
                ;;
        esac
    done
    return 0
}

koopa::pager() { # {{{1
    # """
    # Run less with support for colors (escape characters).
    # @note Updated 2021-06-07.
    #
    # Detail on handling escape sequences:
    # https://major.io/2013/05/21/
    #     handling-terminal-color-escape-sequences-in-less/
    # """
    local pager
    koopa::assert_has_args "$#"
    pager="${PAGER:-}"
    [[ -z "$pager" ]] && pager='less'
    koopa::assert_is_installed "$pager"
    "$pager" -R "$@"
    return 0
}

koopa::roff() { # {{{1
    # """
    # Convert roff markdown files to ronn man pages.
    # @note Updated 2020-08-14.
    # """
    local koopa_prefix
    koopa::assert_is_installed 'ronn'
    koopa_prefix="$(koopa::prefix)"
    (
        koopa::cd "${koopa_prefix}/man"
        ronn --roff ./*.ronn
        koopa::mv -t 'man1' ./*.1
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

koopa::sys_git_pull() { # {{{1
    # """
    # Pull koopa git repo.
    # @note Updated 2021-04-12.
    #
    # Intended for use with 'koopa pull'.
    #
    # This handles updates to Zsh functions that are changed to group
    # non-writable permissions, so Zsh passes 'compaudit' checks.
    # """
    koopa::assert_has_no_args "$#"
    local current_branch default_branch prefix
    (
        prefix="$(koopa::prefix)"
        koopa::cd "$prefix"
        koopa::sys_set_permissions -r "${prefix}/lang/shell/zsh" &>/dev/null
        current_branch="$(koopa::git_branch)"
        default_branch="$(koopa::git_default_branch)"
        koopa::git_pull
        # Ensure other branches, such as develop, are rebased to main branch.
        if [[ "$current_branch" != "$default_branch" ]]
        then
            koopa::git_pull origin "$default_branch"
        fi
        koopa::fix_zsh_permissions
    )
    return 0
}

koopa::sys_info() { # {{{
    # """
    # System information.
    # @note Updated 2021-06-07.
    # """
    local array koopa_prefix nf origin os shell shell_name shell_version uname
    koopa::assert_has_no_args "$#"
    koopa_prefix="$(koopa::prefix)"
    array=(
        "koopa $(koopa::koopa_version) ($(koopa::koopa_date))"
        "URL: $(koopa::koopa_url)"
        "GitHub URL: $(koopa::koopa_github_url)"
    )
    if koopa::is_git_toplevel "$koopa_prefix"
    then
        origin="$( \
            koopa::cd "$koopa_prefix"; \
            koopa::git_remote_url
        )"
        commit="$( \
            koopa::cd "$koopa_prefix"; \
            koopa::git_last_commit_local
        )"
        array+=(
            "Git Remote: ${origin}"
            "Commit: ${commit}"
        )
    fi
    array+=(
        ''
        'Configuration'
        '-------------'
        "Koopa Prefix: ${koopa_prefix}"
        "App Prefix: $(koopa::app_prefix)"
        "Opt Prefix: $(koopa::opt_prefix)"
        "Make Prefix: $(koopa::make_prefix)"
        "User Config Prefix: $(koopa::config_prefix)"
    )
    array+=("")
    # Show neofetch info, if installed.
    if koopa::is_installed 'neofetch'
    then
        readarray -t nf <<< "$(neofetch --stdout)"
        array+=(
            'System information (neofetch)'
            '-----------------------------'
            "${nf[@]:2}"
        )
    else
        if koopa::is_macos
        then
            os="$( \
                printf '%s %s (%s)\n' \
                    "$(sw_vers -productName)" \
                    "$(sw_vers -productVersion)" \
                    "$(sw_vers -buildVersion)" \
            )"
        else
            uname="$(koopa::locate_uname)"
            os="$("$uname" --all)"
            # Alternate approach using Python:
            # > python="$(koopa::locate_python)"
            # > os="$("$python" -mplatform)"
        fi
        shell_name="$(koopa::shell_name)"
        shell_version="$(koopa::get_version "${shell_name}")"
        shell="${shell_name} ${shell_version}"
        array+=(
            'System information'
            '------------------'
            "OS: ${os}"
            "Shell: ${shell}"
            "Architecture: $(koopa::arch)"
        )
    fi
    cat "$(koopa::include_prefix)/ascii-turtle.txt"
    koopa::info_box "${array[@]}"
    return 0
}

koopa::sys_set_permissions() { # {{{1
    # """
    # Set permissions on target prefix(es).
    # @note Updated 2021-05-25.
    # @param -r
    #   Change permissions recursively.
    # """
    koopa::assert_has_args "$#"
    local OPTIND arg chmod chown dict group user
    declare -A dict=(
        [dereference]=1
        [recursive]=0
        [user]=0
    )
    OPTIND=1
    while getopts 'hru' opt
    do
        case "$opt" in
            h)
                dict[dereference]=0
                ;;
            r)
                dict[recursive]=1
                ;;
            u)
                dict[user]=1
                ;;
            \?)
                koopa::invalid_arg
                ;;
        esac
    done
    shift "$((OPTIND-1))"
    koopa::assert_has_args "$#"
    chmod=('koopa::sys_chmod')
    chown=('koopa::sys_chown' '-h')
    if [[ "${dict[recursive]}" -eq 1 ]]
    then
        chmod+=('-R')
        chown+=('-R')
    fi
    chmod+=("$(koopa::sys_chmod_flags)")
    case "${dict[user]}" in
        0)
            user="$(koopa::sys_user)"
            ;;
        1)
            user="$(koopa::user)"
            ;;
    esac
    group="$(koopa::sys_group)"
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

koopa::sys_chgrp() { # {{{1
    # """
    # chgrp with dynamic sudo handling.
    # @note Updated 2020-07-06.
    # """
    local chgrp group
    koopa::assert_has_args "$#"
    group="$(koopa::sys_group)"
    if koopa::is_shared_install
    then
        # NOTE Don't check for admin access here, can slow down functions.
        chgrp=('sudo' 'chgrp')
    else
        chgrp=('chgrp')
    fi
    "${chgrp[@]}" "$group" "$@"
    return 0
}

koopa::sys_chmod() { # {{{1
    # """
    # chmod with dynamic sudo handling.
    # @note Updated 2020-07-06.
    # """
    local chmod
    koopa::assert_has_args "$#"
    if koopa::is_shared_install
    then
    # NOTE Don't check for admin access here, can slow down functions.
        chmod=('sudo' 'chmod')
    else
        chmod=('chmod')
    fi
    "${chmod[@]}" "$@"
    return 0
}

koopa::sys_chmod_flags() { # {{{1
    # """
    # Default recommended flags for chmod.
    # @note Updated 2020-04-16.
    # """
    local flags
    koopa::assert_has_no_args "$#"
    if koopa::is_shared_install
    then
        flags='u+rw,g+rw'
    else
        flags='u+rw,g+r,g-w'
    fi
    koopa::print "$flags"
    return 0
}

koopa::sys_chown() { # {{{1
    # """
    # chown with dynamic sudo handling.
    # @note Updated 2020-07-06.
    # """
    local chown group user
    koopa::assert_has_args "$#"
    if koopa::is_shared_install
    then
        # NOTE Don't check for admin access here, can slow down functions.
        chown=('sudo' 'chown')
    else
        chown=('chown')
    fi
    "${chown[@]}" "$@"
    return 0
}

koopa::sys_cp() { # {{{1
    # """
    # Koopa copy.
    # @note Updated 2020-06-30.
    # """
    local cp
    koopa::assert_has_args "$#"
    cp=('koopa::cp')
    if koopa::is_shared_install
    then
        # NOTE Don't check for admin access here, can slow down functions.
        cp+=('-S')
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
    # @note Updated 2021-05-25.
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
        # NOTE Don't check for admin access here, can slow down functions.
        ln+=('-S')
    fi
    "${ln[@]}" "$source" "$target"
    koopa::sys_set_permissions -h "$target"
    return 0
}

koopa::sys_mkdir() { # {{{1
    # """
    # mkdir with dynamic sudo handling.
    # @note Updated 2020-07-06.
    # """
    local mkdir
    koopa::assert_has_args "$#"
    mkdir=('koopa::mkdir')
    if koopa::is_shared_install
    then
        # NOTE Don't check for admin access here, can slow down functions.
        mkdir+=('-S')
    fi
    "${mkdir[@]}" "$@"
    koopa::sys_set_permissions "$@"
    return 0
}

koopa::sys_mv() { # {{{1
    # """
    # Move a file or directory.
    # @note Updated 2020-07-06.
    # """
    local mv
    koopa::assert_has_args "$#"
    mv=('koopa::mv')
    if koopa::is_shared_install
    then
        # NOTE Don't check for admin access here, can slow down functions.
        mv+=('-S')
    fi
    "${mv[@]}" "$@"
    return 0
}

koopa::sys_rm() { # {{{1
    # """
    # Remove files/directories quietly.
    # @note Updated 2020-06-30.
    # """
    local rm
    koopa::assert_has_args "$#"
    rm=('koopa::rm')
    if koopa::is_shared_install
    then
        # NOTE Don't check for admin access here, can slow down functions.
        rm+=('-S')
    fi
    "${rm[@]}" "$@"
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
            koopa::warning "'${arg}' is exported."
        fi
    done
    return 0
}
