#!/usr/bin/env bash

koopa::add_make_prefix_link() { # {{{1
    # """
    # Ensure 'koopa' is linked inside make prefix.
    # @note Updated 2022-02-03.
    #
    # This is particularly useful for external scripts that source koopa header.
    # This approach works nicely inside a hardened R environment.
    # """
    local dict
    koopa::assert_has_args_le "$#" 1
    koopa::is_shared_install || return 0
    declare -A dict=(
        [koopa_prefix]="${1:-}"
        [make_prefix]="$(koopa::make_prefix)"
    )
    if [[ -z "${dict[koopa_prefix]}" ]]
    then
        dict[koopa_prefix]="$(koopa::koopa_prefix)"
    fi
    dict[source_link]="${dict[koopa_prefix]}/bin/koopa"
    dict[target_link]="${dict[make_prefix]}/bin/koopa"
    [[ -d "${dict[make_prefix]}" ]] || return 0
    [[ -L "${dict[target_link]}" ]] && return 0
    koopa::alert "Adding 'koopa' link inside '${dict[make_prefix]}'."
    koopa::sys_ln "${dict[source_link]}" "${dict[target_link]}"
    return 0
}

koopa::add_monorepo_config_link() { # {{{1
    # """
    # Add koopa configuration link from user's git monorepo.
    # @note Updated 2021-11-24.
    # """
    local dict subdir
    koopa::assert_has_args "$#"
    koopa::assert_has_monorepo
    declare -A dict=(
        [prefix]="$(koopa::monorepo_prefix)"
    )
    for subdir in "$@"
    do
        koopa::add_koopa_config_link \
            "${dict[prefix]}/${subdir}" \
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
    # @note Updated 2022-01-31.
    # """
    local dict name pos
    koopa::assert_has_args "$#"
    declare -A dict=(
        [config]=0
        [xdg_config_home]="$(koopa::xdg_config_home)"
    )
    pos=()
    while (("$#"))
    do
        case "$1" in
            # Flags ------------------------------------------------------------
            '--config')
                dict[config]=1
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
    for name in "$@"
    do
        local filepath
        if [[ "${dict[config]}" -eq 1 ]]
        then
            filepath="${dict[xdg_config_home]}/${name}"
        else
            filepath="${HOME:?}/.${name}"
        fi
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
    # @note Updated 2022-02-03.
    # """
    local dict
    koopa::assert_has_no_args "$#"
    koopa::assert_is_admin
    declare -A dict=(
        [file]='/etc/sudoers.d/sudo'
        [group]="$(koopa::admin_group)"
    )
    dict[string]="%${dict[group]} ALL=(ALL) NOPASSWD: ALL"
    if [[ -f "${dict[file]}" ]] && \
        koopa::file_detect_fixed --sudo "${dict[file]}" "${dict[group]}"
    then
        koopa::alert_success "Passwordless sudo for '${dict[group]}' group \
already enabled at '${dict[file]}'."
        return 0
    fi
    koopa::alert "Modifying '${dict[file]}' to include '${dict[group]}'."
    koopa::sudo_append_string "${dict[string]}" "${dict[file]}"
    koopa::chmod --sudo '0440' "${dict[file]}"
    koopa::alert_success "Passwordless sudo enabled for '${dict[group]}' \
at '${file}'."
    return 0
}

koopa::enable_shell_for_all_users() { # {{{1
    # """
    # Enable shell.
    # @note Updated 2022-02-03.
    # """
    local dict
    koopa::assert_has_args "$#"
    koopa::assert_is_admin
    declare -A dict=(
        [cmd_name]="${1:?}"
        [etc_file]='/etc/shells'
        [make_prefix]="$(koopa::make_prefix)"
        [user]="$(koopa::user)"
    )
    dict[cmd_path]="${dict[make_prefix]}/bin/${dict[cmd_name]}"
    koopa::assert_is_installed "${dict[cmd_path]}"
    koopa::assert_is_file "${dict[etc_file]}"
    if ! koopa::file_detect_fixed "${dict[etc_file]}" "${dict[cmd_path]}"
    then
        koopa::alert "Updating '${dict[etc_file]}' to \
include '${dict[cmd_path]}'."
        koopa::sudo_append_string "${dict[cmd_path]}" "${dict[etc_file]}"
    else
        koopa::alert_note "'${dict[cmd_path]}' already defined \
in '${dict[etc_file]}'."
    fi
    koopa::alert_info "Run 'chsh -s ${dict[cmd_path]} ${dict[user]}' to \
change the default shell."
    return 0
}

koopa::find_user_profile() { # {{{1
    # """
    # Find current user's shell profile configuration file.
    # @note Updated 2022-02-03.
    # """
    local dict
    koopa::assert_has_no_args "$#"
    declare -A dict=(
        [shell]="$(koopa::shell_name)"
    )
    case "${dict[shell]}" in
        'bash')
            dict[file]="${HOME}/.bashrc"
            ;;
        'zsh')
            dict[file]="${HOME}/.zshrc"
            ;;
        *)
            dict[file]="${HOME}/.profile"
            ;;
    esac
    [[ -n "${dict[file]}" ]] || return 1
    koopa::print "${dict[file]}"
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
    # Fix ZSH permissions, to ensure 'compaudit' checks pass.
    # @note Updated 2022-02-03.
    # """
    local app dict
    koopa::assert_has_no_args "$#"
    declare -A app=(
        [zsh]="$(koopa::locate_zsh 2>/dev/null || true)"
    )
    declare -A dict=(
        [app_prefix]="$(koopa::app_prefix)"
        [koopa_prefix]="$(koopa::koopa_prefix)"
        [make_prefix]="$(koopa::make_prefix)"
    )
    koopa::sys_chmod 'g-w' \
        "${dict[koopa_prefix]}/lang/shell/zsh" \
        "${dict[koopa_prefix]}/lang/shell/zsh/functions"
    koopa::is_installed "${app[zsh]}" || return 0
    if [[ -d "${dict[make_prefix]}/share/zsh/site-functions" ]]
    then
        if koopa::str_detect_regex "${app[zsh]}" "^${dict[make_prefix]}"
        then
            koopa::sys_chmod 'g-w' \
                "${dict[make_prefix]}/share/zsh" \
                "${dict[make_prefix]}/share/zsh/site-functions"
        fi
    fi
    if [[ -d "${dict[app_prefix]}" ]]
    then
        if koopa::str_detect_regex \
            "$(koopa::realpath "${app[zsh]}")" "^${dict[app_prefix]}"
        then
            koopa::sys_chmod 'g-w' \
                "${dict[app_prefix]}/zsh/"*'/share/zsh' \
                "${dict[app_prefix]}/zsh/"*'/share/zsh/'* \
                "${dict[app_prefix]}/zsh/"*'/share/zsh/'*'/functions'
        fi
    fi
    return 0
}

koopa::link_dotfile() { # {{{1
    # """
    # Link dotfile.
    # @note Updated 2022-02-03.
    # """
    local dict pos
    koopa::assert_has_args "$#"
    declare -A dict=(
        [config]=0
        [dotfiles_config_link]="$(koopa::dotfiles_config_link)"
        [dotfiles_prefix]="$(koopa::dotfiles_prefix)"
        [dotfiles_private_prefix]="$(koopa::dotfiles_private_prefix)"
        [opt]=0
        [opt_prefix]="$(koopa::opt_prefix)"
        [overwrite]=0
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
            '--opt')
                dict[opt]=1
                shift 1
                ;;
            '--overwrite')
                dict[overwrite]=1
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
    dict[source_subdir]="${1:?}"
    dict[symlink_basename]="${2:-}"
    if [[ -z "${dict[symlink_basename]}" ]]
    then
        dict[symlink_basename]="$(koopa::basename "${dict[source_subdir]}")"
    fi
    if [[ "${dict[opt]}" -eq 1 ]]
    then
        dict[source_prefix]="${dict[opt_prefix]}"
    elif [[ "${dict[private]}" -eq 1 ]]
    then
        dict[source_prefix]="${dict[dotfiles_private_prefix]}"
    else
        dict[source_prefix]="${dict[dotfiles_config_link]}"
        if [[ ! -L "${dict[source_prefix]}" ]]
        then
            koopa::ln "${dict[dotfiles_prefix]}" "${dict[source_prefix]}"
        fi
    fi
    dict[source_path]="${dict[source_prefix]}/${dict[source_subdir]}"
    if [[ "${dict[opt]}" -eq 1 ]] && [[ ! -e "${dict[source_path]}" ]]
    then
        koopa::warn "Does not exist: '${dict[source_path]}'."
        return 0
    fi
    koopa::assert_is_existing "${dict[source_path]}"
    if [[ "${dict[config]}" -eq 1 ]]
    then
        dict[symlink_prefix]="${dict[xdg_config_home]}"
    else
        dict[symlink_prefix]="${HOME:?}"
        dict[symlink_basename]=".${dict[symlink_basename]}"
    fi
    dict[symlink_path]="${dict[symlink_prefix]}/${dict[symlink_basename]}"
    # Inform the user when nuking a broken symlink.
    if [[ "${dict[overwrite]}" -eq 1 ]] ||
        { [[ -L "${dict[symlink_path]}" ]] && \
            [[ ! -e "${dict[symlink_path]}" ]]; }
    then
        koopa::rm "${dict[symlink_path]}"
    elif [[ -e "${dict[symlink_path]}" ]]
    then
        koopa::stop "Existing dotfile: '${dict[symlink_path]}'."
    fi
    koopa::dl "${dict[symlink_path]}" "${dict[source_path]}"
    # Create the parent directory, if necessary.
    dict[symlink_dirname]="$(koopa::dirname "${dict[symlink_path]}")"
    if [[ "${dict[symlink_dirname]}" != "${HOME:?}" ]]
    then
        koopa::mkdir "${dict[symlink_dirname]}"
    fi
    koopa::ln "${dict[source_path]}" "${dict[symlink_path]}"
    return 0
}

koopa::reload_shell() { # {{{1
    # """
    # Reload the current shell.
    # @note Updated 2022-02-03.
    # """
    local app
    koopa::assert_has_no_args "$#"
    declare -A app=(
        [shell]="$(koopa::locate_shell)"
    )
    # shellcheck disable=SC2093
    exec "${app[shell]}" -il
    return 0
}
