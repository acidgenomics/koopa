#!/usr/bin/env bash

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

koopa::system_git_pull() { # {{{1
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
        koopa::system_set_permissions \
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

koopa::system_info() { # {{{
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

koopa::system_set_permissions() { # {{{1
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
    readarray -t chmod_flags <<< "$(koopa::system_chmod_flags)"
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
    group="$(koopa::system_group)"
    local who
    case "$user" in
        0)
            who="$(koopa::system_user)"
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
        koopa::system_chmod "${chmod_flags[@]}" "$arg"
        koopa::system_chown "${chown_flags[@]}" "$arg"
    done
    return 0
}

koopa::update() { # {{{1
    # """
    # Update koopa installation.
    # @note Updated 2020-06-29.
    # """
    local app_prefix config_prefix configure_flags core dotfiles \
        dotfiles_prefix fast koopa_prefix make_prefix repos repo source_ip \
        system user
    koopa_prefix="$(koopa::prefix)"
    # Note that stable releases are not git, and can't be updated.
    if ! koopa::is_git_toplevel "$koopa_prefix"
    then
        version="$(koopa::version)"
        url="$(koopa::url)"
        koopa::note "Stable release of koopa ${version} detected."
        koopa::note "To update, first run the 'uninstall' script."
        koopa::note "Then run the default install command at '${url}'."
        exit 1
    fi
    config_prefix="$(koopa::config_prefix)"
    app_prefix="$(koopa::app_prefix)"
    make_prefix="$(koopa::make_prefix)"
    core=1
    dotfiles=1
    fast=0
    source_ip=
    system=0
    user=0
    while (("$#"))
    do
        case "$1" in
            --fast)
                fast=1
                shift 1
                ;;
            --source-ip=*)
                source_ip="${1#*=}"
                shift 1
                ;;
            --source-ip)
                source_ip="$2"
                shift 2
                ;;
            --system)
                system=1
                shift 1
                ;;
            --user)
                user=1
                shift 1
                ;;
            *)
                koopa::invalid_arg "$1"
                ;;
        esac
    done
    if [[ -n "$source_ip" ]]
    then
        rsync=1
        system=1
    else
        rsync=0
    fi
    if [[ "$fast" -eq 1 ]]
    then
        dotfiles=0
    fi
    if [[ "$user" -eq 1 ]] && [[ "$system" -eq 0 ]]
    then
        core=0
        dotfiles=0
    fi
    if [[ "$system" -eq 1 ]]
    then
        user=1
    fi
    koopa::h1 "Updating koopa at '${koopa_prefix}'."
    koopa::system_set_permissions --recursive "$koopa_prefix"
    if [[ "$rsync" -eq 0 ]]
    then
        # Update koopa.
        if [[ "$core" -eq 1 ]]
        then
            koopa::system_git_pull
        fi
        # Ensure dotfiles are current.
        if [[ "$dotfiles" -eq 1 ]]
        then
            (
                dotfiles_prefix="$(koopa::dotfiles_prefix)"
                cd "$dotfiles_prefix" || exit 1
                # Preivously, this repo was at 'mjsteinbaugh/dotfiles'.
                koopa::git_set_remote_url \
                    'https://github.com/acidgenomics/dotfiles.git'
                koopa::git_reset
                koopa::git_pull origin master
            )
        fi
        koopa::system_set_permissions --recursive "$koopa_prefix"
    fi
    koopa::update_xdg_config
    if [[ "$system" -eq 1 ]]
    then
        koopa::h2 "Updating system configuration."
        koopa::assert_has_sudo
        koopa::dl "App prefix" "${app_prefix}"
        koopa::dl "Config prefix" "${config_prefix}"
        koopa::dl "Make prefix" "${make_prefix}"
        koopa::add_make_prefix_link
        if koopa::is_linux
        then
            koopa::update_etc_profile_d
            koopa::update_ldconfig
        fi
        if koopa::is_installed configure-vm
        then
            # Allow passthrough of specific arguments to 'configure-vm' script.
            configure_flags=("--no-check")
            if [[ "$rsync" -eq 1 ]]
            then
                configure_flags+=("--source-ip=${source_ip}")
            fi
            configure-vm "${configure_flags[@]}"
        fi
        if [[ "$rsync" -eq 0 ]]
        then
            # This can cause some recipes to break.
            # > update-conda
            update-r-packages
            update-python-packages
            update-rust
            update-rust-packages
            update-perlbrew
            if koopa::is_linux
            then
                update-google-cloud-sdk
                update-pyenv
                update-rbenv
            elif koopa::is_macos
            then
                update-homebrew
                update-microsoft-office
                # > update-macos
                # > update-macos-defaults
            fi
        fi
        koopa::fix_zsh_permissions
    fi
    if [[ "$user" -eq 1 ]]
    then
        koopa::h2 "Updating user configuration."
        # Remove legacy directories from user config, if necessary.
        rm -frv "${config_prefix}/"\
{Rcheck,autojump,oh-my-zsh,pyenv,rbenv,spacemacs}
        # Update git repos.
        repos=(
            "${config_prefix}/docker"
            "${config_prefix}/docker-private"
            "${config_prefix}/dotfiles-private"
            "${config_prefix}/scripts-private"
            "${XDG_DATA_HOME}/Rcheck"
            "${HOME}/.emacs.d-doom"
        )
        for repo in "${repos[@]}"
        do
            [ -d "$repo" ] || continue
            (
                koopa::cd "$repo"
                koopa::git_pull
            )
        done
        koopa::install_dotfiles
        koopa::install_dotfiles_private
        koopa::update_spacemacs
    fi
    koopa::success "koopa update was successful."
    koopa::restart
    [[ "$system" -eq 1 ]] && koopa check-system
    return 0
}
