#!/usr/bin/env bash

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
            koopa::note "Skipping '${arg}'."
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
    # @note Updated 2020-07-20.
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
        koopa::cd "$prefix"
        koopa::sys_set_permissions -r "${prefix}/shell/zsh" &>/dev/null
        branch="$(koopa::git_branch)"
        koopa::git_pull
        # Ensure other branches, such as develop, are rebased.
        [[ "$branch" != 'master' ]] && koopa::git_pull origin master
        koopa::fix_zsh_permissions
    )
    return 0
}

koopa::sys_info() { # {{{
    # """
    # System information.
    # @note Updated 2020-07-05.
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
            'System information (neofetch)'
            '-----------------------------'
            "${nf[@]:2}"
        )
    else
        local os
        if koopa::is_macos
        then
            os="$( \
                printf '%s %s (%s)\n' \
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
            'System information'
            '------------------'
            "OS: ${os}"
            "Shell: ${shell}"
        )
    fi
    cat "$(koopa::include_prefix)/ascii-turtle.txt"
    koopa::info_box "${array[@]}"
    return 0
}

koopa::sys_set_permissions() { # {{{1
    # """
    # Set permissions on target prefix(es).
    # @note Updated 2020-07-06.
    # @param -r
    #   Change permissions recursively.
    # """
    koopa::assert_has_args "$#"
    local OPTIND arg chmod chown group recursive user
    recursive=0
    user=0
    OPTIND=1
    while getopts 'ru' opt
    do
        case "$opt" in
            r)
                recursive=1
                ;;
            u)
                user=1
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
    if [[ "$recursive" -eq 1 ]]
    then
        chmod+=('-R')
        chown+=('-R')
    fi
    chmod+=("$(koopa::sys_chmod_flags)")
    case "$user" in
        0)
            user="$(koopa::sys_user)"
            ;;
        1)
            user="${USER:?}"
            ;;
    esac
    group="$(koopa::sys_group)"
    chown+=("${user}:${group}")
    for arg in "$@"
    do
        # Ensure we resolve symlinks here.
        arg="$(realpath "$arg")"
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
    koopa::is_shared_install && cp+=('-S')
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
    # @note Updated 2020-07-06.
    # """
    local ln
    koopa::assert_has_args "$#"
    ln=('koopa::ln')
    koopa::is_shared_install && ln+=('-S')
    "${ln[@]}" "$@"
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
    koopa::is_shared_install && mkdir+=('-S')
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
    koopa::is_shared_install && mv+=('-S')
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
    koopa::is_shared_install && rm+=('-S')
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

koopa::url() { # {{{1
    # """
    # Koopa URL.
    # @note Updated 2020-04-16.
    # """
    koopa::assert_has_no_args "$#"
    koopa::variable 'koopa-url'
    return 0
}

koopa::variables() { # {{{1
    # """
    # Edit koopa variables.
    # @note Updated 2020-06-30.
    # """
    koopa::assert_has_no_args "$#"
    koopa::assert_is_installed vim
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
