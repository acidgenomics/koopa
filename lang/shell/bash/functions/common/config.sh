#!/usr/bin/env bash

koopa::add_make_prefix_link() { # {{{1
    # """
    # Ensure 'koopa' is linked inside make prefix.
    # @note Updated 2020-07-20.
    #
    # This is particularly useful for external scripts that source koopa header.
    # This approach works nicely inside a hardened R environment.
    # """
    local koopa_prefix make_prefix source_link target_link
    koopa::assert_has_args_le "$#" 1
    koopa::is_shared_install || return 0
    koopa_prefix="${1:-}"
    [[ -z "$koopa_prefix" ]] && koopa_prefix="$(koopa::koopa_prefix)"
    make_prefix="$(koopa::make_prefix)"
    [[ -d "$make_prefix" ]] || return 0
    target_link="${make_prefix}/bin/koopa"
    [[ -L "$target_link" ]] && return 0
    koopa::alert "Adding 'koopa' link inside '${make_prefix}'."
    source_link="${koopa_prefix}/bin/koopa"
    koopa::sys_ln "$source_link" "$target_link"
    return 0
}

koopa::add_monorepo_config_link() { # {{{1
    # """
    # Add koopa configuration link from user's git monorepo.
    # @note Updated 2021-05-24.
    # """
    local monorepo_prefix subdir
    koopa::assert_has_args "$#"
    koopa::assert_has_monorepo
    monorepo_prefix="$(koopa::monorepo_prefix)"
    for subdir in "$@"
    do
        koopa::add_koopa_config_link \
            "${monorepo_prefix}/${subdir}" \
            "$subdir"
    done
    return 0
}

koopa::add_to_user_profile() { # {{{1
    # """
    # Add koopa configuration to user profile.
    # @note Updated 2021-11-11.
    # """
    local dict
    koopa::assert_has_no_args "$#"
    declare -A dict=(
        [file]="$(koopa::find_user_profile)"
    )
    koopa::alert "Adding koopa activation to '${dict[file]}'."
    read -r -d '' "dict[string]" << END || true
__koopa_activate_user_profile() { # {{{1
    # """
    # Activate koopa shell for current user.
    # @note Updated 2021-11-11.
    # @seealso
    # - https://koopa.acidgenomics.com/
    # """
    local script xdg_config_home
    [ "\$#" -eq 0 ] || return 1
    xdg_config_home="\${XDG_CONFIG_HOME:-}"
    if [ -z "\$xdg_config_home" ]
    then
        xdg_config_home="\${HOME:?}/.config"
    fi
    script="\${xdg_config_home}/koopa/activate"
    if [ -r "\$script" ]
    then
        # shellcheck source=/dev/null
        . "\$script"
    fi
    return 0
}

__koopa_activate_user_profile
END
    koopa::append_string "\n${dict[string]}" "${dict[file]}"
    return 0
}

koopa::delete_dotfile() { # {{{1
    # """
    # Delete a dot file.
    # @note Updated 2020-07-20.
    # """
    local filepath name
    koopa::assert_has_args "$#"
    for name in "$@"
    do
        name="${1:?}"
        filepath="${HOME:?}/.${name}"
        if [[ -L "$filepath" ]]
        then
            koopa::alert "Removing '${filepath}'."
            koopa::rm "$filepath"
        elif [[ -f "$filepath" ]] || [[ -d "$filepath" ]]
        then
            koopa::warn "Not a symlink: '${filepath}'."
        fi
    done
    return 0
}

koopa::disable_passwordless_sudo() { # {{{1
    # """
    # Disable passwordless sudo access for all admin users.
    # @note Updated 2021-03-01.
    # Consider using 'has_passwordless_sudo' as a check step here.
    # """
    local file
    koopa::assert_is_admin
    file='/etc/sudoers.d/sudo'
    if [[ -f "$file" ]]
    then
        koopa::alert "Removing sudo permission file at '${file}'."
        koopa::rm --sudo "$file"
    fi
    koopa::alert_success 'Passwordless sudo is disabled.'
    return 0
}

koopa::enable_passwordless_sudo() { # {{{1
    # """
    # Enable passwordless sudo access for all admin users.
    # @note Updated 2021-10-25.
    # """
    local file group string
    koopa::assert_has_no_args "$#"
    koopa::is_root && return 0
    koopa::assert_is_admin
    file='/etc/sudoers.d/sudo'
    group="$(koopa::admin_group)"
    if [[ -f "$file" ]] && \
        koopa::file_match_fixed --sudo "$file" "$group"
    then
        koopa::alert_success "sudo already configured at '${file}'."
        return 0
    fi
    koopa::alert "Modifying '${file}' to include '${group}'."
    string="%${group} ALL=(ALL) NOPASSWD: ALL"
    koopa::sudo_append_string "$string" "$file"
    koopa::chmod --sudo '0440' "$file"
    koopa::alert_success "Passwordless sudo enabled for '${group}' \
at '${file}'."
    return 0
}

koopa::enable_shell() { # {{{1
    # """
    # Enable shell.
    # @note Updated 2021-10-25.
    # """
    local cmd_name cmd_path etc_file make_prefix user
    koopa::assert_has_args "$#"
    koopa::is_admin || return 0
    cmd_name="${1:?}"
    make_prefix="$(koopa::make_prefix)"
    cmd_path="${make_prefix}/bin/${cmd_name}"
    etc_file='/etc/shells'
    [[ -f "$etc_file" ]] || return 0
    koopa::alert "Updating '${etc_file}' to include '${cmd_path}'."
    if ! koopa::file_match_fixed "$etc_file" "$cmd_path"
    then
        koopa::sudo_append_string "$cmd_path" "$etc_file"
    else
        koopa::alert_success "'${cmd_path}' already defined in '${etc_file}'."
    fi
    user="$(koopa::user)"
    koopa::alert_note "Run 'chsh -s ${cmd_path} ${user}' to change the \
default shell."
    return 0
}

koopa::find_user_profile() { # {{{1
    # """
    # Find current user's shell profile configuration file.
    # @note Updated 2021-05-15.
    # """
    local file shell
    koopa::assert_has_no_args "$#"
    shell="$(koopa::shell_name)"
    case "$shell" in
        'bash')
            file="${HOME}/.bashrc"
            ;;
        'zsh')
            file="${HOME}/.zshrc"
            ;;
        *)
            file="${HOME}/.profile"
            ;;
    esac
    [[ -n "$file" ]] || return 1
    koopa::print "$file"
    return 0
}

koopa::fix_pyenv_permissions() { # {{{1
    # """
    # Ensure Python pyenv shims have correct permissions.
    # @note Updated 2020-07-30.
    # """
    local pyenv_prefix
    koopa::assert_has_no_args "$#"
    pyenv_prefix="$(koopa::pyenv_prefix)"
    [[ -d "${pyenv_prefix}/shims" ]] || return 0
    koopa::sys_chmod '0777' "${pyenv_prefix}/shims"
    return 0
}

koopa::fix_rbenv_permissions() { # {{{1
    # """
    # Ensure Ruby rbenv shims have correct permissions.
    # @note Updated 2020-07-30.
    # """
    local rbenv_prefix
    koopa::assert_has_no_args "$#"
    rbenv_prefix="$(koopa::rbenv_prefix)"
    [[ -d "${rbenv_prefix}/shims" ]] || return 0
    koopa::sys_chmod '0777' "${rbenv_prefix}/shims"
    return 0
}

koopa::fix_zsh_permissions() { # {{{1
    # """
    # Fix ZSH permissions, to ensure compaudit checks pass.
    # @note Updated 2021-03-18.
    # """
    local app_prefix koopa_prefix make_prefix
    koopa::assert_has_no_args "$#"
    koopa::alert 'Fixing Zsh permissions.'
    koopa_prefix="$(koopa::koopa_prefix)"
    koopa::sys_chmod 'g-w' \
        "${koopa_prefix}/lang/shell/zsh" \
        "${koopa_prefix}/lang/shell/zsh/functions"
    koopa::is_installed 'zsh' || return 0
    make_prefix="$(koopa::make_prefix)"
    if [[ -d "${make_prefix}/share/zsh/site-functions" ]]
    then
        if koopa::str_match_regex \
            "$(koopa::which zsh)" "^${make_prefix}"
        then
            koopa::sys_chmod 'g-w' \
                "${make_prefix}/share/zsh" \
                "${make_prefix}/share/zsh/site-functions"
        fi
    fi
    app_prefix="$(koopa::app_prefix)"
    if [[ -d "$app_prefix" ]]
    then
        if koopa::str_match_regex \
            "$(koopa::which_realpath zsh)" "^${app_prefix}"
        then
            koopa::sys_chmod 'g-w' \
                "${app_prefix}/zsh/"*'/share/zsh' \
                "${app_prefix}/zsh/"*'/share/zsh/'* \
                "${app_prefix}/zsh/"*'/share/zsh/'*'/functions'
        fi
    fi
    koopa::alert_success 'Zsh permissions should pass compaudit checks.'
    return 0
}

koopa::link_dotfile() { # {{{1
    # """
    # Link dotfile.
    # @note Updated 2021-06-14.
    # """
    local pos source_path source_prefix source_subdir
    local symlink_basename symlink_dirname symlink_path symlink_prefix
    koopa::assert_has_args "$#"
    declare -A dict=(
        [config]=0
        [dotfiles_config_link]="$(koopa::dotfiles_config_link)"
        [dotfiles_prefix]="$(koopa::dotfiles_prefix)"
        [dotfiles_private_config_link]="$(koopa::dotfiles_private_config_link)"
        [force]=0
        [opt]=0
        [opt_prefix]="$(koopa::opt_prefix)"
        [private]=0
        [xdg_config_home]="$(koopa::xdg_config_home)"
    )
    pos=()
    while (("$#"))
    do
        case "$1" in
            '--config')
                dict[config]=1
                shift 1
                ;;
            '--force')
                dict[force]=1
                shift 1
                ;;
            '--opt')
                dict[opt]=1
                shift 1
                ;;
            '--private')
                dict[private]=1
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
    koopa::assert_has_args_le "$#" 2
    source_subdir="${1:?}"
    symlink_basename="${2:-}"
    if [[ -z "$symlink_basename" ]]
    then
        symlink_basename="$(koopa::basename "$source_subdir")"
    fi
    if [[ "${dict[opt]}" -eq 1 ]]
    then
        source_prefix="${dict[opt_prefix]}"
    elif [[ "${dict[private]}" -eq 1 ]]
    then
        source_prefix="${dict[dotfiles_private_config_link]}"
    else
        source_prefix="${dict[dotfiles_config_link]}"
        if [[ ! -L "$source_prefix" ]]
        then
            koopa::ln "${dict[dotfiles_prefix]}" "$source_prefix"
        fi
    fi
    source_path="${source_prefix}/${source_subdir}"
    if [[ "${dict[opt]}" -eq 1 ]] && [[ ! -e "$source_path" ]]
    then
        koopa::warn "Does not exist: '${source_path}'."
        return 0
    fi
    koopa::assert_is_existing "$source_path"
    if [[ "${dict[config]}" -eq 1 ]]
    then
        symlink_prefix="${dict[xdg_config_home]}"
    else
        symlink_prefix="${HOME:?}"
        symlink_basename=".${symlink_basename}"
    fi
    symlink_path="${symlink_prefix}/${symlink_basename}"
    # Inform the user when nuking a broken symlink.
    if [[ "${dict[force]}" -eq 1 ]] ||
        { [[ -L "$symlink_path" ]] && [[ ! -e "$symlink_path" ]]; }
    then
        koopa::rm "$symlink_path"
    elif [[ -e "$symlink_path" ]]
    then
        koopa::stop "Existing dotfile: '${symlink_path}'."
    fi
    koopa::dl "$symlink_path" "$source_path"
    # Create the parent directory, if necessary.
    symlink_dirname="$(koopa::dirname "$symlink_path")"
    if [[ "$symlink_dirname" != "${HOME:?}" ]]
    then
        koopa::mkdir "$symlink_dirname"
    fi
    koopa::ln "$source_path" "$symlink_path"
    return 0
}

koopa::reload_shell() { # {{{1
    # """
    # Reload the current shell.
    # @note Updated 2021-03-18.
    # """
    koopa::assert_has_no_args "$#"
    # shellcheck disable=SC2093
    exec "${SHELL:?}" -il
    return 0
}
