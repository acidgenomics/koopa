#!/usr/bin/env bash

koopa::add_config_link() { # {{{1
    # """
    # Add a symlink into the koopa configuration directory.
    # @note Updated 2020-07-04.
    # """
    local config_prefix dest_file dest_name source_file
    koopa::assert_has_args_le "$#" 2
    source_file="${1:?}"
    koopa::assert_is_existing "$source_file"
    source_file="$(realpath "$source_file")"
    dest_name="${2:-}"
    [[ -z "$dest_name" ]] && dest_name="$(basename "$source_file")"
    config_prefix="$(koopa::config_prefix)"
    dest_file="${config_prefix}/${dest_name}"
    koopa::rm "$dest_file"
    koopa::ln "$source_file" "$dest_file"
    return 0
}

koopa::add_make_prefix_link() { # {{{1
    # """
    # Ensure 'koopa' is linked inside make prefix.
    # @note Updated 2020-07-07.
    #
    # This is particularly useful for external scripts that source koopa header.
    # This approach works nicely inside a hardened R environment.
    # """
    local koopa_prefix make_prefix source_link target_link
    koopa::assert_has_args_le "$#" 1
    koopa::is_shared_install || return 0
    koopa_prefix="${1:-}"
    [[ -z "$koopa_prefix" ]] && koopa_prefix="$(koopa::prefix)"
    make_prefix="$(koopa::make_prefix)"
    [[ -d "$make_prefix" ]] || return 0
    target_link="${make_prefix}/bin/koopa"
    [[ -L "$target_link" ]] && return 0
    koopa::info "Adding \"koopa\" link inside \"${make_prefix}\"."
    source_link="${koopa_prefix}/bin/koopa"
    koopa::sys_ln "$source_link" "$target_link"
    return 0
}

koopa::add_monorepo_config_link() { # {{{1
    # """
    # Add koopa configuration link from user's git monorepo.
    # @note Updated 2020-07-04.
    # """
    local monorepo_prefix subdir
    koopa::assert_has_args "$#"
    koopa::assert_has_monorepo
    monorepo_prefix="$(koopa::monorepo_prefix)"
    for subdir in "$@"
    do
        koopa::add_config_link "${monorepo_prefix}/${subdir}"
    done
    return 0
}

koopa::add_to_user_profile() { # {{{1
    # """
    # Add koopa configuration to user profile.
    # @note Updated 2020-07-03.
    # """
    local source_file target_file
    koopa::assert_has_args "$#"
    target_file="$(koopa::find_user_profile)"
    source_file="$(koopa::prefix)/shell/posix/include/profile.sh"
    koopa::assert_is_file "$source_file"
    koopa::info "Adding koopa activation to '${target_file}'."
    touch "$target_file"
    cat "$source_file" >> "$target_file"
    return 0
}

koopa::add_user_to_etc_passwd() { # {{{1
    # """
    # Any any type of user, including domain user to passwd file.
    # @note Updated 2020-07-03.
    #
    # Necessary for running 'chsh' with a Kerberos / Active Directory domain
    # account, on AWS or Azure for example.
    #
    # Note that this function will enable use of RStudio for domain users.
    # """
    local passwd_file user user_string
    koopa::assert_has_args_le "$#" 1
    koopa::assert_is_linux
    passwd_file='/etc/passwd'
    koopa::assert_is_file "$passwd_file"
    user="${1:-${USER:?}}"
    user_string="$(getent passwd "$user")"
    koopa::info "Updating \"${passwd_file}\" to include \"${user}\"."
    if ! sudo grep -q "$user" "$passwd_file"
    then
        sudo sh -c "printf \"%s\n\" \"${user_string}\" >> \"${passwd_file}\""
    else
        koopa::note "$user already defined in \"${passwd_file}\"."
    fi
    return 0
}

koopa::add_user_to_group() { # {{{1
    # """
    # Add user to group.
    # @note Updated 2020-07-07.
    #
    # Alternate approach:
    # > usermod -a -G group user
    #
    # @examples
    # koopa::add_user_to_group "docker"
    # """
    local group user
    koopa::assert_has_args_le "$#" 2
    koopa::assert_is_installed gpasswd
    group="${1:?}"
    user="${2:-${USER:?}}"
    koopa::info "Adding user \"${user}\" to group \"${group}\"."
    sudo gpasswd --add "$user" "$group"
    return 0
}

koopa::delete_dotfile() { # {{{1
    # """
    # Delete a dot file.
    # @note Updated 2020-07-05.
    # """
    local filepath name
    koopa::assert_has_args "$#"
    for name in "$@"
    do
        name="${1:?}"
        filepath="${HOME:?}/.${name}"
        if [[ -L "$filepath" ]]
        then
            koopa::info "Removing \"${filepath}\"."
            rm -f "$filepath"
        elif [[ -f "$filepath" ]] || [[ -d "$filepath" ]]
        then
            koopa::warning "Not a symlink: \"${filepath}\"."
        fi
    done
    return 0
}

koopa::enable_passwordless_sudo() { # {{{1
    # """
    # Enable passwordless sudo access for all admin users.
    # @note Updated 2020-07-07.
    # """
    local group string sudo_file
    koopa::assert_has_no_args "$#"
    koopa::is_root && return 0
    koopa::assert_has_sudo
    group="$(koopa::admin_group)"
    sudo_file='/etc/sudoers.d/sudo'
    sudo touch "$sudo_file"
    if sudo grep -q "$group" "$sudo_file"
    then
        koopa::success "Passwordless sudo enabled for \"${group}\" group."
        return 0
    fi
    koopa::info "Updating '${sudo_file}' to include \"${group}\"."
    string="%${group} ALL=(ALL) NOPASSWD: ALL"
    sudo sh -c "printf \"%s\n\" \"$string\" >> \"${sudo_file}\""
    sudo chmod -v 0440 "$sudo_file"
    koopa::success "Passwordless sudo enabled for \"${group}\"."
    return 0
}

koopa::enable_shell() { # {{{1
    # """
    # Enable shell.
    # @note Updated 2020-07-07.
    # """
    local cmd_name cmd_path etc_file
    koopa::assert_has_args "$#"
    koopa::has_sudo || return 0
    cmd_name="${1:?}"
    cmd_path="$(koopa::make_prefix)/bin/${cmd_name}"
    etc_file='/etc/shells'
    [[ -f "$etc_file" ]] || return 0
    koopa::info "Updating \"${etc_file}\" to include \"${cmd_path}\"."
    if ! grep -q "$cmd_path" "$etc_file"
    then
        sudo sh -c "printf \"%s\n\" \"${cmd_path}\" >> \"${etc_file}\""
    else
        koopa::success "\"${cmd_path}\" already defined in \"${etc_file}\"."
    fi
    koopa::note "Run \"chsh -s ${cmd_path} ${USER}\" to change default shell."
    return 0
}

koopa::find_user_profile() { # {{{1
    # """
    # Find current user's shell profile configuration file.
    # @note Updated 2020-06-30.
    # """
    local file shell
    koopa::assert_has_no_args "$#"
    shell="$(koopa::shell)"
    case "$shell" in
        bash)
            file="${HOME}/.bashrc"
            ;;
        zsh)
            file="${HOME}/.zshrc"
            ;;
    esac
    koopa::print "$file"
    return 0
}

koopa::fix_pyenv_permissions() { # {{{1
    # """
    # Ensure Python pyenv shims have correct permissions.
    # @note Updated 2020-02-11.
    # """
    local pyenv_prefix
    koopa::assert_has_no_args "$#"
    pyenv_prefix="$(koopa::pyenv_prefix)"
    [[ -d "${pyenv_prefix}/shims" ]] || return 0
    koopa::info 'Fixing Python pyenv shim permissions.'
    koopa::sys_chmod -v 0777 "${pyenv_prefix}/shims"
    return 0
}

koopa::fix_rbenv_permissions() { # {{{1
    # """
    # Ensure Ruby rbenv shims have correct permissions.
    # @note Updated 2020-02-11.
    # """
    local rbenv_prefix
    koopa::assert_has_no_args "$#"
    rbenv_prefix="$(koopa::rbenv_prefix)"
    [[ -d "${rbenv_prefix}/shims" ]] || return 0
    koopa::info 'Fixing Ruby rbenv shim permissions.'
    koopa::sys_chmod -v 0777 "${rbenv_prefix}/shims"
    return 0
}

koopa::fix_zsh_permissions() { # {{{1
    # """
    # Fix ZSH permissions, to ensure compaudit checks pass.
    # @note Updated 2020-07-05.
    # """
    local cellar_prefix koopa_prefix make_prefix zsh_exe
    koopa::assert_has_no_args "$#"
    koopa::info 'Fixing Zsh permissions to pass compaudit checks.'
    koopa_prefix="$(koopa::prefix)"
    koopa::sys_chmod -v g-w \
        "${koopa_prefix}/shell/zsh" \
        "${koopa_prefix}/shell/zsh/functions"
    koopa::is_installed zsh || return 0
    zsh_exe="$(koopa::which_realpath zsh)"
    make_prefix="$(koopa::make_prefix)"
    if [[ -d "${make_prefix}/share/zsh/site-functions" ]]
    then
        if koopa::str_match_regex "$zsh_exe" "^${make_prefix}"
        then
            koopa::sys_chmod -v g-w \
                "${make_prefix}/share/zsh" \
                "${make_prefix}/share/zsh/site-functions"
        fi
    fi
    cellar_prefix="$(koopa::cellar_prefix)"
    if [[ -d "$cellar_prefix" ]]
    then
        if koopa::str_match_regex "$zsh_exe" "^${cellar_prefix}"
        then
            koopa::sys_chmod -v g-w \
                "${cellar_prefix}/zsh/"*"/share/zsh" \
                "${cellar_prefix}/zsh/"*"/share/zsh/"* \
                "${cellar_prefix}/zsh/"*"/share/zsh/"*"/functions"
        fi
    fi
    return 0
}

koopa::git_clone_dotfiles() { # {{{1
    # """
    # Clone dotfiles repo.
    # @note Updated 2020-07-04.
    # """
    koopa::assert_has_no_args "$#"
    koopa::git_clone \
        'https://github.com/acidgenomics/dotfiles.git' \
        "$(koopa::dotfiles_prefix)"
    return 0
}

koopa::install_dotfiles() { # {{{1
    # """
    # Install dot files.
    # @note Updated 2020-07-07.
    # """
    local prefix script
    koopa::assert_has_no_args "$#"
    prefix="$(koopa::dotfiles_prefix)"
    [[ ! -d "$prefix" ]] && koopa::git_clone_dotfiles
    koopa::add_config_link "$prefix"
    script="${prefix}/install"
    koopa::assert_is_file "$script"
    "$script"
    return 0
}

koopa::install_dotfiles_private() { # {{{1
    # """
    # Install private dot files.
    # @note Updated 2020-07-07.
    # """
    local prefix script
    koopa::assert_has_no_args "$#"
    prefix="$(koopa::dotfiles_private_prefix)"
    koopa::add_monorepo_config_link 'dotfiles-private'
    [[ ! -d "$prefix" ]] && koopa::git_clone_dotfiles_private
    script="${prefix}/install"
    koopa::assert_is_file "$script"
    "$script"
    return 0
}

koopa::install_mike() { # {{{1
    # """
    # Install additional Mike-specific config files.
    # @note Updated 2020-07-07.
    #
    # Note that these repos require SSH key to be set on GitHub.
    # """
    koopa::assert_has_no_args "$#"
    koopa::install_dotfiles
    koopa::install_dotfiles_private
    koopa::add_monorepo_config_link \
        'docker' \
        'dotfiles-private' \
        'scripts-private'
    return 0
}

koopa::java_update_alternatives() {
    # """
    # Update Java alternatives.
    # @note Updated 2020-07-05.
    #
    # This step is intentionally skipped for non-admin installs, when calling
    # from 'install-openjdk' script.
    # """
    local prefix priority
    koopa::assert_has_args_eq "$#" 1
    koopa::is_shared_install || return 0
    koopa::is_installed update-alternatives || return 0
    prefix="${1:?}"
    prefix="$(realpath "$prefix")"
    priority=100
    sudo rm -fv /var/lib/alternatives/java
    sudo update-alternatives --install \
        '/usr/bin/java' \
        'java' \
        "${prefix}/bin/java" \
        "$priority"
    sudo update-alternatives --set \
        'java' \
        "${prefix}/bin/java"
    sudo rm -fv /var/lib/alternatives/javac
    sudo update-alternatives --install \
        '/usr/bin/javac' \
        'javac' \
        "${prefix}/bin/javac" \
        "$priority"
    sudo update-alternatives --set \
        'javac' \
        "${prefix}/bin/javac"
    sudo rm -fv /var/lib/alternatives/jar
    sudo update-alternatives --install \
        '/usr/bin/jar' \
        'jar' \
        "${prefix}/bin/jar" \
        "$priority"
    sudo update-alternatives --set \
        'jar' \
        "${prefix}/bin/jar"
    update-alternatives --display java
    update-alternatives --display javac
    update-alternatives --display jar
    return 0
}

koopa::link_docker() { # {{{1
    # """
    # Link Docker library onto data disk for VM.
    # @note Updated 2020-07-05.
    # """
    local dd_link_prefix etc_source lib_n lib_sys os_id
    koopa::assert_has_no_args "$#"
    koopa::is_installed docker || return 0
    koopa::assert_has_sudo
    # e.g. '/mnt/data01/n' to '/n' for AWS.
    dd_link_prefix="$(koopa::data_disk_link_prefix)"
    [[ -d "$dd_link_prefix" ]] || return 0
    koopa::info 'Updating Docker configuration.'
    koopa::assert_is_linux
    koopa::assert_is_installed systemctl
    koopa::note 'Stopping Docker.'
    sudo systemctl stop docker
    lib_sys='/var/lib/docker'
    lib_n="${dd_link_prefix}/var/lib/docker"
    os_id="$(koopa::os_id)"
    koopa::note "Moving Docker lib from '${lib_sys}' to '${lib_n}'."
    etc_source="$(koopa::prefix)/os/${os_id}/etc/docker"
    if [[ -d "$etc_source" ]]
    then
        sudo mkdir -pv "/etc/docker"
        sudo ln -fnsv "${etc_source}"* "/etc/docker/."
    fi
    sudo rm -frv "$lib_sys"
    sudo mkdir -pv "$lib_n"
    sudo ln -fnsv "$lib_n" "$lib_sys"
    koopa::note 'Restarting Docker.'
    sudo systemctl enable docker
    sudo systemctl start docker
    return 0
}

koopa::link_dotfile() { # {{{1
    # """
    # Link dotfile.
    # @note Updated 2020-07-07.
    # """
    local config dot_dir dot_repo force pos private source_name symlink_name
    koopa::assert_has_args "$#"
    config=0
    force=0
    private=0
    pos=()
    while (("$#"))
    do
        case "$1" in
            --config)
                config=1
                shift 1
                ;;
            --force)
                force=1
                shift 1
                ;;
            --private)
                private=1
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
    koopa::assert_has_args_le "$#" 2
    source_name="$1"
    symlink_name="${2:-}"
    if [[ "$private" -eq 1 ]]
    then
        dot_dir="$(koopa::dotfiles_private_config_link)"
    else
        # e.g. ~/.config/koopa/dotfiles
        dot_dir="$(koopa::dotfiles_config_link)"
        # Note that this step automatically links into koopa config for users.
        if [[ ! -d "$dot_dir" ]]
        then
            dot_repo="$(koopa::dotfiles_prefix)"
            koopa::rm "$dot_dir"
            koopa::ln "$dot_repo" "$dot_dir"
        fi
    fi
    koopa::assert_is_dir "$dot_dir"
    source_path="${dot_dir}/${source_name}"
    koopa::assert_is_existing "$source_path"
    # Define optional target symlink name.
    if [[ -z "$symlink_name" ]]
    then
        symlink_name="$(basename "$source_path")"
    fi
    # Add link either in HOME (default) or XDG_CONFIG_HOME.
    if [[ "$config" -eq 1 ]]
    then
        symlink_path="${XDG_CONFIG_HOME:?}/${symlink_name}"
    else
        symlink_path="${HOME:?}/.${symlink_name}"
    fi
    # Inform the user when nuking a broken symlink.
    if [[ "$force" -eq 1 ]] ||
        { [[ -L "$symlink_path" ]] && [[ ! -e "$symlink_path" ]]; }
    then
        koopa::rm "$symlink_path"
    elif [[ -e "$symlink_path" ]]
    then
        koopa::stop "Existing dotfile: \"${symlink_path}\"."
        return 1
    fi
    koopa::dl "$symlink_path" "$source_path"
    symlink_dn="$(dirname "$symlink_path")"
    [[ "$symlink_dn" != "${HOME:?}" ]] && koopa::mkdir "$symlink_dn"
    koopa::ln "$source_path" "$symlink_path"
    return 0
}

koopa::remove_user_from_group() { # {{{1
    # """
    # Remove user from group.
    # @note Updated 2020-07-05.
    #
    # @examples
    # koopa::remove_user_from_group "docker"
    # """
    local group user
    koopa::assert_has_args_le "$#" 2
    koopa::assert_is_installed gpasswd sudo
    koopa::assert_has_sudo
    group="${1:?}"
    user="${2:-${USER}}"
    sudo gpasswd --delete "$user" "$group"
    return 0
}

koopa::uninstall_dotfiles() { # {{{1
    # """
    # Uninstall dot files.
    # @note Updated 2020-07-05.
    # """
    local prefix script
    koopa::assert_has_no_args "$#"
    prefix="$(koopa::dotfiles_prefix)"
    if [[ ! -d "$prefix" ]]
    then
        koopa::note "No dotfiles at '${prefix}'."
        return 0
    fi
    script="${prefix}/uninstall"
    koopa::assert_is_file "$script"
    "$script"
    return 0
}

koopa::uninstall_dotfiles_private() { # {{{1
    # """
    # Uninstall private dot files.
    # @note Updated 2020-07-05.
    # """
    local prefix script
    koopa::assert_has_no_args "$#"
    prefix="$(koopa::dotfiles_private_prefix)"
    if [[ ! -d "$prefix" ]]
    then
        koopa::note "No private dotfiles at '${prefix}'."
        return 0
    fi
    script="${prefix}/uninstall"
    koopa::assert_is_file "$script"
    "$script"
    return 0
}

koopa::update_etc_profile_d() { # {{{1
    # """
    # Link shared 'zzz-koopa.sh' configuration file into '/etc/profile.d/'.
    # @note Updated 2020-07-05.
    # """
    local file koopa_prefix string
    koopa::assert_has_no_args "$#"
    koopa::is_linux || return 0
    koopa::is_shared_install || return 0
    koopa::assert_has_sudo
    file='/etc/profile.d/zzz-koopa.sh'
    # Early return if file exists and is not a symlink.
    # Previous verisons of koopa prior to 2020-05-09 created a symlink here.
    if [[ -f "$file" ]] && [[ ! -L "$file" ]]
    then
        return 0
    fi
    sudo rm -fv "$file"
    koopa_prefix="$(koopa::prefix)"
    read -r -d '' string << END || true
#!/bin/sh

# koopa shell
# https://koopa.acidgenomics.com/
# shellcheck source=/dev/null
. "${koopa_prefix}/activate"
END
    koopa::sudo_write_string "$string" "$file"
}

koopa::update_ldconfig() { # {{{1
    # """
    # Update dynamic linker (LD) configuration.
    # @note Updated 2020-06-30.
    # """
    local conf_source dest_file os_id prefix source_file
    koopa::assert_has_no_args "$#"
    koopa::is_linux || return 0
    [[ -d '/etc/ld.so.conf.d' ]] || return 0
    koopa::assert_is_installed ldconfig
    koopa::assert_has_sudo
    os_id="$(koopa::os_id)"
    prefix="$(koopa::prefix)"
    conf_source="${prefix}/os/${os_id}/etc/ld.so.conf.d"
    [[ -d "$conf_source" ]] || return 0
    # Create symlinks with "koopa-" prefix.
    # Note that we're using shell globbing here.
    # https://unix.stackexchange.com/questions/218816
    koopa::h2 'Updating ldconfig in "/etc/ld.so.conf.d/".'
    for source_file in "${conf_source}/"*".conf"
    do
        dest_file="/etc/ld.so.conf.d/koopa-$(basename "$source_file")"
        sudo ln -fnsv "$source_file" "$dest_file"
    done
    sudo ldconfig
    return 0
}

koopa::update_lmod_config() { # {{{1
    # """
    # Link lmod configuration files in '/etc/profile.d/'.
    # @note Updated 2020-07-05.
    #
    # Need to check for this case:
    # ln: failed to create symbolic link '/etc/fish/conf.d/z00_lmod.fish':
    # No suchfile or directory
    # """
    local etc_dir init_dir
    koopa::assert_has_no_args "$#"
    koopa::is_linux || return 0
    koopa::assert_has_sudo
    init_dir="$(koopa::app_prefix)/lmod/apps/lmod/lmod/init"
    [[ -d "$init_dir" ]] || return 0
    koopa::h2 'Updating Lmod init configuration.'
    etc_dir='/etc/profile.d'
    sudo mkdir -pv "$etc_dir"
    # bash, zsh
    sudo ln -fnsv "${init_dir}/profile" "${etc_dir}/z00_lmod.sh"
    # csh, tcsh
    sudo ln -fnsv "${init_dir}/cshrc" "${etc_dir}/z00_lmod.csh"
    # fish
    if koopa::is_installed fish
    then
        etc_dir='/etc/fish/conf.d'
        sudo mkdir -pv "$etc_dir"
        sudo ln -fnsv "${init_dir}/profile.fish" "${etc_dir}/z00_lmod.fish"
    fi
    return 0
}
