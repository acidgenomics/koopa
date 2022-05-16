#!/usr/bin/env bash

koopa_configure_nim() {
    koopa_configure_app_packages \
        --name-fancy='Nim' \
        --name='nim' \
        "$@"
}

koopa_configure_node() {
    koopa_configure_app_packages \
        --name-fancy='Node.js' \
        --name='node' \
        "$@"
}

koopa_configure_ruby() {
    koopa_configure_app_packages \
        --name-fancy='Ruby' \
        --name='ruby' \
        "$@"
}

koopa_configure_rust() {
    koopa_configure_app_packages \
        --name-fancy='Rust' \
        --name='rust' \
        "$@"
}

koopa_delete_dotfile() {
    # """
    # Delete a dot file.
    # @note Updated 2022-01-31.
    # """
    local dict name pos
    koopa_assert_has_args "$#"
    declare -A dict=(
        [config]=0
        [xdg_config_home]="$(koopa_xdg_config_home)"
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
                koopa_invalid_arg "$1"
                ;;
            *)
                pos+=("$1")
                shift 1
                ;;
        esac
    done
    [[ "${#pos[@]}" -gt 0 ]] && set -- "${pos[@]}"
    koopa_assert_has_args "$#"
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
            koopa_alert "Removing '${filepath}'."
            koopa_rm "$filepath"
        elif [[ -f "$filepath" ]] || [[ -d "$filepath" ]]
        then
            koopa_warn "Not a symlink: '${filepath}'."
        fi
    done
    return 0
}

koopa_disable_passwordless_sudo() {
    # """
    # Disable passwordless sudo access for all admin users.
    # @note Updated 2021-03-01.
    # Consider using 'has_passwordless_sudo' as a check step here.
    # """
    local file
    koopa_assert_is_admin
    file='/etc/sudoers.d/sudo'
    if [[ -f "$file" ]]
    then
        koopa_alert "Removing sudo permission file at '${file}'."
        koopa_rm --sudo "$file"
    fi
    koopa_alert_success 'Passwordless sudo is disabled.'
    return 0
}

koopa_enable_passwordless_sudo() {
    # """
    # Enable passwordless sudo access for all admin users.
    # @note Updated 2022-02-17.
    # """
    local dict
    koopa_assert_has_no_args "$#"
    koopa_assert_is_admin
    declare -A dict=(
        [file]='/etc/sudoers.d/sudo'
        [group]="$(koopa_admin_group)"
    )
    dict[string]="%${dict[group]} ALL=(ALL) NOPASSWD: ALL"
    if [[ -f "${dict[file]}" ]] && \
        koopa_file_detect_fixed \
            --file="${dict[file]}" \
            --pattern="${dict[group]}" \
            --sudo
    then
        koopa_alert_success "Passwordless sudo for '${dict[group]}' group \
already enabled at '${dict[file]}'."
        return 0
    fi
    koopa_alert "Modifying '${dict[file]}' to include '${dict[group]}'."
    koopa_sudo_append_string \
        --file="${dict[file]}" \
        --string="${dict[string]}"
    koopa_chmod --sudo '0440' "${dict[file]}"
    koopa_alert_success "Passwordless sudo enabled for '${dict[group]}' \
at '${file}'."
    return 0
}

koopa_enable_shell_for_all_users() {
    # """
    # Enable shell.
    # @note Updated 2022-04-08.
    #
    # @usage
    # > koopa_enable_shell_for_all_users APP...
    #
    # @examples
    # > koopa_enable_shell_for_all_users \
    # >     '/opt/koopa/bin/bash' \
    # >     /opt/koopa/bin/zsh'
    # """
    local app apps dict
    koopa_assert_has_args "$#"
    koopa_is_admin || return 0
    declare -A dict=(
        [etc_file]='/etc/shells'
        [user]="$(koopa_user)"
    )
    apps=("$@")
    # Intentionally not checking to see whether file exists here.
    # > koopa_assert_is_executable "${apps[@]}"
    for app in "${apps[@]}"
    do
        if ! koopa_file_detect_fixed \
            --file="${dict[etc_file]}" \
            --pattern="$app"
        then
            koopa_alert "Updating '${dict[etc_file]}' to include '${app}'."
            koopa_sudo_append_string \
                --file="${dict[etc_file]}" \
                --string="$app"
        else
            koopa_alert_note "'$app' already defined in '${dict[etc_file]}'."
        fi
    done
    if [[ "$#" -eq 1 ]]
    then
        koopa_alert_info "Run 'chsh -s ${apps[0]} ${dict[user]}' to change \
the default shell."
    fi
    return 0
}

koopa_find_user_profile() {
    # """
    # Find current user's shell profile configuration file.
    # @note Updated 2022-02-03.
    # """
    local dict
    koopa_assert_has_no_args "$#"
    declare -A dict=(
        [shell]="$(koopa_shell_name)"
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
    koopa_print "${dict[file]}"
    return 0
}

koopa_fix_pyenv_permissions() {
    # """
    # Ensure Python pyenv shims have correct permissions.
    # @note Updated 2022-04-07.
    # """
    local pyenv_prefix
    koopa_assert_has_no_args "$#"
    pyenv_prefix="$(koopa_pyenv_prefix)"
    [[ -d "${pyenv_prefix}/shims" ]] || return 0
    koopa_chmod '0777' "${pyenv_prefix}/shims"
    return 0
}

koopa_fix_rbenv_permissions() {
    # """
    # Ensure Ruby rbenv shims have correct permissions.
    # @note Updated 2022-04-07.
    # """
    local rbenv_prefix
    koopa_assert_has_no_args "$#"
    rbenv_prefix="$(koopa_rbenv_prefix)"
    [[ -d "${rbenv_prefix}/shims" ]] || return 0
    koopa_chmod '0777' "${rbenv_prefix}/shims"
    return 0
}

koopa_fix_zsh_permissions() {
    # """
    # Fix ZSH permissions, to ensure 'compaudit' checks pass.
    # @note Updated 2022-04-12.
    # """
    local app dict
    koopa_assert_has_no_args "$#"
    declare -A dict=(
        [app_prefix]="$(koopa_app_prefix)"
        [koopa_prefix]="$(koopa_koopa_prefix)"
    )
    koopa_chmod 'g-w' \
        "${dict[koopa_prefix]}/lang/shell/zsh" \
        "${dict[koopa_prefix]}/lang/shell/zsh/functions"
    if [[ -d "${dict[app_prefix]}/zsh" ]]
    then
        koopa_chmod 'g-w' \
            "${dict[app_prefix]}/zsh/"*'/share/zsh' \
            "${dict[app_prefix]}/zsh/"*'/share/zsh/'* \
            "${dict[app_prefix]}/zsh/"*'/share/zsh/'*'/functions'
    fi
    return 0
}

# FIXME Rename '--opt' to '--from-opt'.
# FIXME Rename '--config' to '--into-xdg-config-home'.

koopa_link_dotfile() {
    # """
    # Link dotfile.
    # @note Updated 2022-04-04.
    # """
    local dict pos
    koopa_assert_has_args "$#"
    declare -A dict=(
        [dotfiles_config_link]="$(koopa_dotfiles_config_link)"
        [dotfiles_prefix]="$(koopa_dotfiles_prefix)"
        [dotfiles_private_prefix]="$(koopa_dotfiles_private_prefix)"
        [from_opt]=0
        [into_xdg_config_home]=0
        [opt_prefix]="$(koopa_opt_prefix)"
        [overwrite]=0
        [private]=0
        [xdg_config_home]="$(koopa_xdg_config_home)"
    )
    pos=()
    while (("$#"))
    do
        case "$1" in
            '--from-opt')
                dict[from_opt]=1
                shift 1
                ;;
            '--into-xdg-config-home')
                dict[into_xdg_config_home]=1
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
                koopa_invalid_arg "$1"
                ;;
            *)
                pos+=("$1")
                shift 1
                ;;
        esac
    done
    [[ "${#pos[@]}" -gt 0 ]] && set -- "${pos[@]}"
    koopa_assert_has_args_le "$#" 2
    dict[source_subdir]="${1:?}"
    dict[symlink_basename]="${2:-}"
    if [[ -z "${dict[symlink_basename]}" ]]
    then
        dict[symlink_basename]="$(koopa_basename "${dict[source_subdir]}")"
    fi
    if [[ "${dict[from_opt]}" -eq 1 ]]
    then
        dict[source_prefix]="${dict[opt_prefix]}"
    elif [[ "${dict[private]}" -eq 1 ]]
    then
        dict[source_prefix]="${dict[dotfiles_private_prefix]}"
    else
        dict[source_prefix]="${dict[dotfiles_config_link]}"
        if [[ ! -L "${dict[source_prefix]}" ]]
        then
            koopa_ln "${dict[dotfiles_prefix]}" "${dict[source_prefix]}"
        fi
    fi
    dict[source_path]="${dict[source_prefix]}/${dict[source_subdir]}"
    if [[ "${dict[from_opt]}" -eq 1 ]] && [[ ! -e "${dict[source_path]}" ]]
    then
        koopa_warn "Does not exist: '${dict[source_path]}'."
        return 0
    fi
    koopa_assert_is_existing "${dict[source_path]}"
    if [[ "${dict[into_xdg_config_home]}" -eq 1 ]]
    then
        dict[symlink_prefix]="${dict[xdg_config_home]}"
    else
        dict[symlink_prefix]="${HOME:?}"
        dict[symlink_basename]=".${dict[symlink_basename]}"
    fi
    dict[symlink_path]="${dict[symlink_prefix]}/${dict[symlink_basename]}"
    if [[ "${dict[overwrite]}" -eq 1 ]] ||
        { [[ -L "${dict[symlink_path]}" ]] && \
            [[ ! -e "${dict[symlink_path]}" ]]; }
    then
        koopa_rm "${dict[symlink_path]}"
    fi
    if [[ -e "${dict[symlink_path]}" ]] && \
        [[ ! -L "${dict[symlink_path]}" ]]
    then
        koopa_alert_note "Exists and not symlink: '${dict[symlink_path]}'."
        return 0
    fi
    koopa_alert "Linking dotfile from '${dict[source_path]}' \
to '${dict[symlink_path]}'."
    dict[symlink_dirname]="$(koopa_dirname "${dict[symlink_path]}")"
    if [[ "${dict[symlink_dirname]}" != "${HOME:?}" ]]
    then
        koopa_mkdir "${dict[symlink_dirname]}"
    fi
    koopa_ln "${dict[source_path]}" "${dict[symlink_path]}"
    return 0
}

koopa_reload_shell() {
    # """
    # Reload the current shell.
    # @note Updated 2022-02-03.
    # """
    local app
    koopa_assert_has_no_args "$#"
    declare -A app=(
        [shell]="$(koopa_locate_shell)"
    )
    # shellcheck disable=SC2093
    exec "${app[shell]}" -il
    return 0
}
