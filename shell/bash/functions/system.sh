#!/usr/bin/env bash

_koopa_add_local_bins_to_path() {  # {{{1
    # """
    # Add local build bins to PATH (e.g. '/usr/local').
    # @note Updated 2020-06-29.
    #
    # This will recurse through the local library and find 'bin/' subdirs.
    # Note: read '-a' flag doesn't work on macOS.
    # """
    [[ "$#" -eq 0 ]] || return 1
    local dir dirs
    _koopa_add_to_path_start "$(_koopa_make_prefix)/bin"
    IFS=$'\n' read -r -d '' dirs <<< "$(_koopa_find_local_bin_dirs)"
    unset IFS
    for dir in "${dirs[@]}"
    do
        _koopa_add_to_path_start "$dir"
    done
    return 0
}

_koopa_info_box() {  # {{{1
    # """
    # Info box.
    # @note Updated 2020-06-29.
    #
    # Using unicode box drawings here.
    # Note that we're truncating lines inside the box to 68 characters.
    # """
    [[ "$#" -gt 0 ]] || return 1
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

_koopa_script_name() {  # {{{1
    # """
    # Get the calling script name.
    # @note Updated 2020-06-29.
    #
    # Note that we're using 'caller' approach, which is Bash-specific.
    # """
    [[ "$#" -eq 0 ]] || return 1
    local file x
    file="$( \
        caller \
        | head -n 1 \
        | cut -d ' ' -f 2 \
    )"
    x="$(_koopa_basename "$file")"
    [[ -n "$x" ]] || return 0
    _koopa_print "$x"
    return 0
}

_koopa_system_info() { # {{{
    # """
    # System information.
    # @note Updated 2020-06-29.
    # """
    [[ "$#" -eq 0 ]] || return 1
    local koopa_prefix
    koopa_prefix="$(_koopa_prefix)"
    local array
    array=(
        "koopa $(_koopa_version) ($(_koopa_date))"
        "URL: $(_koopa_url)"
        "GitHub URL: $(_koopa_github_url)"
    )
    if _koopa_is_git_toplevel "$koopa_prefix"
    then
        local origin
        origin="$( \
            cd "$koopa_prefix" || exit 1; \
            git config --get remote.origin.url \
        )"
        array+=(
            "Git Remote: ${origin}"
            "Commit: $(_koopa_commit)"
        )
    fi
    array+=(
        ""
        "Configuration"
        "-------------"
        "Koopa Prefix: ${koopa_prefix}"
        "Config Prefix: $(_koopa_config_prefix)"
        "App Prefix: $(_koopa_app_prefix)"
        "Make Prefix: $(_koopa_make_prefix)"
    )
    if _koopa_is_linux
    then
        array+=("Cellar Prefix: $(_koopa_cellar_prefix)")
    fi
    array+=("")
    # Show neofetch info, if installed.
    if _koopa_is_installed neofetch
    then
        local nf
        readarray -t nf <<< "$(neofetch --stdout)"
        array+=(
            "System information (neofetch)"
            "-----------------------------"
            "${nf[@]:2}"
        )
    else
        local os
        if _koopa_is_macos
        then
            os="$( \
                printf "%s %s (%s)\n" \
                    "$(sw_vers -productName)" \
                    "$(sw_vers -productVersion)" \
                    "$(sw_vers -buildVersion)" \
            )"
        else
            if _koopa_is_installed python
            then
                os="$(python -mplatform)"
            else
                os="$(uname --all)"
            fi
        fi
        local shell_name
        shell_name="$KOOPA_SHELL"
        local shell_version
        shell_version="$(_koopa_get_version "${shell_name}")"
        local shell
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
    cat "$(_koopa_include_prefix)/ascii-turtle.txt"
    _koopa_info_box "${array[@]}"
    return 0
}

_koopa_update() { # {{{1
    # """
    # Update koopa installation.
    # @note Updated 2020-06-29.
    # """
    local app_prefix config_prefix configure_flags core dotfiles \
        dotfiles_prefix fast koopa_prefix make_prefix repos repo source_ip \
        system user
    koopa_prefix="$(_koopa_prefix)"
    # Note that stable releases are not git, and can't be updated.
    if ! _koopa_is_git_toplevel "$koopa_prefix"
    then
        version="$(_koopa_version)"
        url="$(_koopa_url)"
        _koopa_note "Stable release of koopa ${version} detected."
        _koopa_note "To update, first run the 'uninstall' script."
        _koopa_note "Then run the default install command at '${url}'."
        exit 1
    fi
    config_prefix="$(_koopa_config_prefix)"
    app_prefix="$(_koopa_app_prefix)"
    make_prefix="$(_koopa_make_prefix)"
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
                _koopa_invalid_arg "$1"
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
    _koopa_h1 "Updating koopa at '${koopa_prefix}'."
    _koopa_set_permissions --recursive "$koopa_prefix"
    if [[ "$rsync" -eq 0 ]]
    then
        # Update koopa.
        if [[ "$core" -eq 1 ]]
        then
            _koopa_system_git_pull
        fi
        # Ensure dotfiles are current.
        if [[ "$dotfiles" -eq 1 ]]
        then
            (
                dotfiles_prefix="$(_koopa_dotfiles_prefix)"
                cd "$dotfiles_prefix" || exit 1
                _koopa_git_reset
                _koopa_git_pull origin master
            )
        fi
        _koopa_set_permissions --recursive "$koopa_prefix"
    fi
    _koopa_update_xdg_config
    if [[ "$system" -eq 1 ]]
    then
        _koopa_h2 "Updating system configuration."
        _koopa_assert_has_sudo
        _koopa_dl "App prefix" "${app_prefix}"
        _koopa_dl "Config prefix" "${config_prefix}"
        _koopa_dl "Make prefix" "${make_prefix}"
        _koopa_add_make_prefix_link
        if _koopa_is_linux
        then
            _koopa_update_etc_profile_d
            _koopa_update_ldconfig
        fi
        if _koopa_is_installed configure-vm
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
            if _koopa_is_linux
            then
                update-google-cloud-sdk
                update-pyenv
                update-rbenv
            elif _koopa_is_macos
            then
                update-homebrew
                update-microsoft-office
                # > update-macos
                # > update-macos-defaults
            fi
        fi
        _koopa_fix_zsh_permissions
    fi
    if [[ "$user" -eq 1 ]]
    then
        _koopa_h2 "Updating user configuration."
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
                _koopa_cd "$repo"
                _koopa_git_pull
            )
        done
        _koopa_install_dotfiles
        _koopa_install_dotfiles_private
        _koopa_update_spacemacs
    fi
    _koopa_success "koopa update was successful."
    _koopa_restart
    [[ "$system" -eq 1 ]] && koopa check-system
    return 0
}
