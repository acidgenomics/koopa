#!/usr/bin/env bash

koopa::_id() { # {{{1
    # """
    # Return ID string.
    # @note Updated 2020-06-30.
    # """
    koopa::assert_has_args "$#"
    local x
    x="$(id "$@")"
    koopa::print "$x"
    return 0
}

koopa::add_local_bins_to_path() { # {{{1
    # """
    # Add local build bins to PATH (e.g. '/usr/local').
    # @note Updated 2020-06-29.
    #
    # This will recurse through the local library and find 'bin/' subdirs.
    # Note: read '-a' flag doesn't work on macOS.
    # """
    koopa::assert_has_no_args "$#"
    local dir dirs
    koopa::add_to_path_start "$(koopa::make_prefix)/bin"
    IFS=$'\n' read -r -d '' dirs <<< "$(koopa::find_local_bin_dirs)"
    unset IFS
    for dir in "${dirs[@]}"
    do
        koopa::add_to_path_start "$dir"
    done
    return 0
}

koopa::admin_group() { # {{{1
    # """
    # Return the administrator group.
    # @note Updated 2020-06-30.
    #
    # Usage of 'groups' here is terribly slow for domain users.
    # Currently seeing this with CPI AWS Ubuntu config.
    # Instead of grep matching against 'groups' return, just set the
    # expected default per Linux distro. In the event that we're unsure,
    # the function will intentionally error.
    # """
    koopa::assert_has_no_args "$#"
    local group
    if koopa::is_root
    then
        group='root'
    elif koopa::is_debian
    then
        group='sudo'
    elif koopa::is_fedora
    then
        group='wheel'
    elif koopa::is_macos
    then
        group='admin'
    else
        koopa::stop 'Failed to detect admin group.'
    fi
    koopa::print "$group"
    return 0
}

koopa::cd_tmp_dir() { # {{{1
    # """
    # Prepare and navigate (cd) to temporary directory.
    # @note Updated 2020-06-30.
    #
    # Used primarily for cellar build scripts.
    # """
    koopa::assert_has_args_le "$#" 1
    local dir
    dir="${1:-$(koopa::tmp_dir)}"
    rm -fr "$dir"
    mkdir -p "$dir"
    koopa::cd "$dir"
    return 0
}

koopa::check_system() { # {{{1
    # """
    # Check system.
    # @note Updated 2020-06-30.
    # """
    koopa::assert_has_no_args "$#"
    koopa::assert_is_installed Rscript
    local koopa_prefix
    koopa_prefix="$(koopa::prefix)"
    export KOOPA_FORCE=1
    set +u
    # shellcheck disable=SC1090
    source "${koopa_prefix}/activate"
    set -u
    Rscript --vanilla "$(koopa::include_prefix)/check-system.R"
    koopa::disk_check
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
    barpad="$(printf "━%.0s" {1..70})"
    printf "  %s%s%s  \n" "┏" "$barpad" "┓"
    for i in "${array[@]}"
    do
        printf "  ┃ %-68s ┃  \n" "${i::68}"
    done
    printf "  %s%s%s  \n\n" "┗" "$barpad" "┛"
    return 0
}

koopa::script_name() { # {{{1
    # """
    # Get the calling script name.
    # @note Updated 2020-06-29.
    #
    # Note that we're using 'caller' approach, which is Bash-specific.
    # """
    koopa::assert_has_no_args "$#"
    local file x
    file="$( \
        caller \
        | head -n 1 \
        | cut -d ' ' -f 2 \
    )"
    x="$(koopa::basename "$file")"
    [[ -n "$x" ]] || return 0
    koopa::print "$x"
    return 0
}

koopa::sys_git_pull() { # {{{1
    # """
    # Pull koopa git repo.
    # @note Updated 2020-07-04.
    #
    # Intended for use with 'koopa pull'.
    #
    # This handles updates to Zsh functions that are changed to group
    # non-writable permissions, so Zsh passes 'compaudit' checks.
    # """
    koopa::assert_has_no_args "$#"
    local branch prefix
    (
        prefix="$(koopa::prefix)"
        cd "$prefix" || exit 1
        koopa::sys_set_permissions \
            --recursive "${prefix}/shell/zsh" \
            >/dev/null 2>&1
        branch="$(koopa::git_branch)"
        koopa::git_pull
        # Ensure other branches, such as develop, are rebased.
        if [[ "$branch" != "master" ]]
        then
            koopa::git_pull origin master
        fi
        koopa::fix_zsh_permissions &>/dev/null
    )
    return 0
}

koopa::sys_info() { # {{{
    # """
    # System information.
    # @note Updated 2020-06-30.
    # """
    koopa::assert_has_no_args "$#"
    local array koopa_prefix nf origin shell shell_name shell_version
    koopa_prefix="$(koopa::prefix)"
    array=(
        "koopa $(koopa::version) ($(koopa::date))"
        "URL: $(koopa::url)"
        "GitHub URL: $(koopa::github_url)"
    )
    if koopa::is_git_toplevel "$koopa_prefix"
    then
        origin="$( \
            cd "$koopa_prefix" || exit 1; \
            koopa::git_remote_url
        )"
        commit="$( \
            cd "$koopa_prefix" || exit 1; \
            koopa::git_last_commit_local
        )"
        array+=(
            "Git Remote: ${origin}"
            "Commit: ${commit}"
        )
    fi
    array+=(
        ""
        "Configuration"
        "-------------"
        "Koopa Prefix: ${koopa_prefix}"
        "Config Prefix: $(koopa::config_prefix)"
        "App Prefix: $(koopa::app_prefix)"
        "Make Prefix: $(koopa::make_prefix)"
    )
    if koopa::is_linux
    then
        array+=("Cellar Prefix: $(koopa::cellar_prefix)")
    fi
    array+=("")
    # Show neofetch info, if installed.
    if koopa::is_installed neofetch
    then
        readarray -t nf <<< "$(neofetch --stdout)"
        array+=(
            "System information (neofetch)"
            "-----------------------------"
            "${nf[@]:2}"
        )
    else
        local os
        if koopa::is_macos
        then
            os="$( \
                printf "%s %s (%s)\n" \
                    "$(sw_vers -productName)" \
                    "$(sw_vers -productVersion)" \
                    "$(sw_vers -buildVersion)" \
            )"
        else
            if koopa::is_installed python
            then
                os="$(python -mplatform)"
            else
                os="$(uname --all)"
            fi
        fi
        shell_name="$KOOPA_SHELL"
        shell_version="$(koopa::get_version "${shell_name}")"
        shell="${shell_name} ${shell_version}"
        array+=(
            "System information"
            "------------------"
            "OS: ${os}"
            "Shell: ${shell}"
            ""
        )
    fi
    array+=("Run 'koopa check' to verify installation.")
    cat "$(koopa::include_prefix)/ascii-turtle.txt"
    koopa::info_box "${array[@]}"
    return 0
}

koopa::sys_set_permissions() { # {{{1
    # """
    # Set permissions on target prefix(es).
    # @note Updated 2020-07-04.
    #
    # @param --recursive
    #   Change permissions recursively.
    # @param --user
    #   Change ownership to current user, rather than koopa default, which is
    #   root for shared installs.
    # """
    koopa::assert_has_args "$#"
    local recursive
    recursive=0
    local user
    user=0
    local verbose
    verbose=0
    pos=()
    while (("$#"))
    do
        case "$1" in
            --recursive)
                recursive=1
                shift 1
                ;;
            --user)
                user=1
                shift 1
                ;;
            --verbose)
                verbose=1
                shift 1
                ;;
            --)
                shift 1
                break
                ;;
            --*|-*)
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
    # chmod flags.
    local chmod_flags
    readarray -t chmod_flags <<< "$(koopa::sys_chmod_flags)"
    if [[ "$recursive" -eq 1 ]]
    then
        # Note that '-R' instead of '--recursive' has better cross-platform
        # support on macOS and BusyBox.
        chmod_flags+=("-R")
    fi
    if [[ "$verbose" -eq 1 ]]
    then
        # Note that '-v' instead of '--verbose' has better cross-platform
        # support on macOS and BusyBox.
        chmod_flags+=("-v")
    fi
    # chown flags.
    local chown_flags
    # Note that '-h' instead of '--no-dereference' has better cross-platform
    # support on macOS and BusyBox.
    chown_flags=("-h")
    if [[ "$recursive" -eq 1 ]]
    then
        # Note that '-R' instead of '--recursive' has better cross-platform
        # support on macOS and BusyBox.
        chown_flags+=("-R")
    fi
    if [[ "$verbose" -eq 1 ]]
    then
        # Note that '-v' instead of '--verbose' has better cross-platform
        # support on macOS and BusyBox.
        chown_flags+=("-v")
    fi
    local group
    group="$(koopa::sys_group)"
    local who
    case "$user" in
        0)
            who="$(koopa::sys_user)"
            ;;
        1)
            who="$(koopa::user)" \
            ;;
    esac
    chown_flags+=("${who}:${group}")
    # Loop across input and set permissions.
    for arg in "$@"
    do
        # Ensure we resolve symlinks here.
        arg="$(realpath "$arg")"
        koopa::sys_chmod "${chmod_flags[@]}" "$arg"
        koopa::sys_chown "${chown_flags[@]}" "$arg"
    done
    return 0
}

# FIXME THIS SHOULD HANDLE KOOPA GROUP AUTOMATICALLY.
koopa::sys_chgrp() { # {{{1
    # """
    # chgrp with dynamic sudo handling.
    # @note Updated 2020-07-05.
    # """
    koopa::assert_has_args "$#"
    local exe group
    group="$(koopa::sys_group)"
    if koopa::is_shared_install
    then
        exe=('sudo' 'chgrp')
    else
        exe=('chgrp')
    fi
    koopa::assert_has_args "$#"
    "${exe[@]}" "$group" "$@"
    return 0
}

koopa::sys_chmod() { # {{{1
    # """
    # chmod with dynamic sudo handling.
    # @note Updated 2020-02-16.
    # """
    koopa::assert_has_args "$#"
    if koopa::is_shared_install
    then
        sudo chmod "$@"
    else
        chmod "$@"
    fi
    return 0
}

koopa::sys_chmod_flags() {
    # """
    # Default recommended flags for chmod.
    # @note Updated 2020-04-16.
    # """
    koopa::assert_has_no_args "$#"
    local flags
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
    # @note Updated 2020-02-16.
    # """
    koopa::assert_has_args "$#"
    if koopa::is_shared_install
    then
        sudo chown "$@"
    else
        chown "$@"
    fi
    return 0
}

# FIXME BROKEN
koopa::sys_cp() { # {{{1
    # """
    # Koopa copy.
    # @note Updated 2020-06-30.
    # """
    if koopa::is_shared_install
    then
        sudo -E "$(koopa::cp "$@")"
    else
        koopa::cp "$@"
    fi
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
    koopa::assert_has_no_args "$#"
    local group
    if koopa::is_shared_install
    then
        group="$(koopa::admin_group)"
    else
        group="$(koopa::group)"
    fi
    koopa::print "$group"
    return 0
}

# FIXME BROKEN
koopa::sys_ln() { # {{{1
    # """
    # Create a symlink quietly.
    # @note Updated 2020-07-04.
    # """
    if koopa::is_shared_install
    then
        sudo -E "$(koopa::ln "$@")"
    else
        koopa::ln "$@"
    fi
    return 0
}

# FIXME BROKEN
koopa::sys_mkdir() { # {{{1
    # """
    # mkdir with dynamic sudo handling.
    # @note Updated 2020-07-05.
    # """
    koopa::assert_has_args "$#"
    if koopa::is_shared_install
    then
        # FIXME RETHINK THIS.
        sudo -E "$(koopa::mkdir "$@")"
    else
        koopa::mkdir "$@"
    fi
    # FIXME SIMPLIFY
    koopa::sys_chmod "$(koopa::sys_chmod_flags)" "$@"
    koopa::sys_chgrp "$@"
    return 0
}

# FIXME BROKEN
koopa::sys_mv() { # {{{1
    # """
    # Move a file or directory.
    # @note Updated 2020-07-04.
    # """
    if koopa::is_shared_install
    then
        sudo -E "$(koopa::mv "$@")"
    else
        koopa::mv "$@"
    fi
    return 0
}

# FIXME BROKEN
koopa::sys_rm() { # {{{1
    # """
    # Remove files/directories quietly.
    # @note Updated 2020-06-30.
    # """
    koopa::assert_has_args "$#"
    if koopa::is_shared_install
    then
        sudo -E "$(koopa::rm "$@")"
    else
        koopa::rm "$@"
    fi
    return 0
}

koopa::sys_user() { # {{{1
    # """
    # Set the koopa installation system user.
    # @note Updated 2020-07-04.
    # """
    koopa::assert_has_no_args "$#"
    local user
    if koopa::is_shared_install
    then
        user='root'
    else
        user="$(koopa::user)"
    fi
    koopa::print "$user"
    return 0
}

koopa::view_latest_tmp_log_file() { # {{{1
    # """
    # View the latest temporary log file.
    # @note Updated 2020-07-05.
    # """
    koopa::assert_has_no_args "$#"
    koopa::assert_is_installed find
    local dir log_file
    dir="${TMPDIR:-/tmp}"
    log_file="$( \
        find "$dir" \
            -mindepth 1 \
            -maxdepth 1 \
            -type f \
            -name "koopa-$(koopa::user_id)-*" \
            | sort \
            | tail -n 1 \
    )"
    [[ -f "$log_file" ]] || return 1
    koopa::info "Viewing '${log_file}'."
    # Note that this will skip to the end automatically.
    koopa::pager +G "$log_file"
    return 0
}
