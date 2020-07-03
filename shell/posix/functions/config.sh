#!/bin/sh
# shellcheck disable=SC2039

_koopa_add_config_link() { # {{{1
    # """
    # Add a symlink into the koopa configuration directory.
    # @note Updated 2020-01-12.
    # """
    [ "$#" -gt 0 ] || return 1
    local config_dir
    config_dir="$(_koopa_config_prefix)"
    local source_file
    source_file="${1:?}"
    _koopa_assert_is_existing "$source_file"
    source_file="$(realpath "$source_file")"
    local dest_name
    dest_name="${2:?}"
    local dest_file
    dest_file="${config_dir}/${dest_name}"
    rm -f "$dest_file"
    ln -fnsv "$source_file" "$dest_file"
    return 0
}

_koopa_add_make_prefix_link() { # {{{1
    # """
    # Ensure 'koopa' is linked inside make prefix.
    # @note Updated 2020-06-30.
    #
    # This is particularly useful for external scripts that source koopa header.
    # This approach works nicely inside a hardened R environment.
    # """
    _koopa_is_shared_install || return 0
    local koopa_prefix make_prefix source_link target_link
    koopa_prefix="${1:-"$(_koopa_prefix)"}"
    make_prefix="$(_koopa_make_prefix)"
    [ -d "$make_prefix" ] || return 0
    target_link="${make_prefix}/bin/koopa"
    [ -L "$target_link" ] && return 0
    _koopa_h1 "Adding 'koopa' link inside '${make_prefix}'."
    source_link="${koopa_prefix}/bin/koopa"
    _koopa_ln "$source_link" "$target_link"
    return 0
}

_koopa_add_to_user_profile() { # {{{1
    # """
    # Add koopa configuration to user profile.
    # @note Updated 2020-06-30.
    # """
    [ "$#" -eq 0 ] || return 1
    local source_file target_file
    target_file="$(_koopa_find_user_profile)"
    source_file="$(_koopa_prefix)/shell/posix/include/profile.sh"
    _koopa_assert_is_file "$source_file"
    _koopa_h1 "Adding koopa activation to '${target_file}'."
    touch "$target_file"
    cat "$source_file" >> "$target_file"
    return 0
}

_koopa_add_user_to_etc_passwd() { # {{{1
    # """
    # Any any type of user, including domain user to passwd file.
    # @note Updated 2020-04-24.
    #
    # Necessary for running 'chsh' with a Kerberos / Active Directory domain
    # account, on AWS or Azure for example.
    #
    # Note that this function will enable use of RStudio for domain users.
    # """
    _koopa_assert_is_linux
    local passwd_file user user_string
    passwd_file="/etc/passwd"
    [ -f "$passwd_file" ] || return 1
    user="${1:-${USER:?}}"
    user_string="$(getent passwd "$user")"
    _koopa_h2 "Updating '${passwd_file}' to include '${user}'."
    if ! sudo grep -q "$user" "$passwd_file"
    then
        sudo sh -c "printf '%s\n' '${user_string}' >> '${passwd_file}'"
    else
        _koopa_note "$user already defined in '${passwd_file}'."
    fi
    return 0
}

_koopa_add_user_to_group() { # {{{1
    # """
    # Add user to group.
    # @note Updated 2020-06-30.
    #
    # Alternate approach:
    # > usermod -a -G group user
    #
    # @examples
    # _koopa_add_user_to_group "docker"
    # """
    [ "$#" -gt 0 ] || return 1
    _koopa_assert_is_installed gpasswd
    local group
    group="${1:?}"
    local user
    user="${2:-${USER:?}}"
    sudo gpasswd --add "$user" "$group"
}

_koopa_data_disk_check() { # {{{1
    # """
    # Check data disk configuration.
    # @note Updated 2020-06-30.
    # """
    [ "$#" -eq 0 ] || return 1
    _koopa_is_linux || return 0
    # e.g. '/n'.
    local data_disk_link_prefix
    data_disk_link_prefix="$(_koopa_data_disk_link_prefix)"
    if [ -L "$data_disk_link_prefix" ] && [ ! -e "$data_disk_link_prefix" ]
    then
        _koopa_warning "Data disk link error: '${data_disk_link_prefix}'."
    fi
    # e.g. '/usr/local/opt'.
    local app_prefix
    app_prefix="$(_koopa_app_prefix)"
    if [ -L "$app_prefix" ] && [ ! -e "$app_prefix" ]
    then
        _koopa_warning "App prefix link error: '${app_prefix}'."
    fi
    return 0
}

_koopa_delete_dotfile() { # {{{1
    # """
    # Delete a dot file.
    # @note Updated 2020-06-30.
    # """
    [ "$#" -gt 0 ] || return 1
    local name
    name="${1:?}"
    local filepath
    filepath="${HOME:?}/.${name}"
    if [ -L "$filepath" ]
    then
        _koopa_h2 "Removing '${filepath}'."
        rm -f "$filepath"
    elif [ -f "$filepath" ] || [ -d "$filepath" ]
    then
        _koopa_warning "Not a symlink: '${filepath}'."
    fi
    return 0
}

_koopa_enable_passwordless_sudo() { # {{{1
    # """
    # Enable passwordless sudo access for all admin users.
    # @note Updated 2020-06-30.
    # """
    [ "$#" -eq 0 ] || return 1
    _koopa_is_root && return 0
    local group
    group="$(_koopa_group)"
    local sudo_file
    sudo_file="/etc/sudoers.d/sudo"
    sudo touch "$sudo_file"
    if sudo grep -q "$group" "$sudo_file"
    then
        _koopa_success "Passwordless sudo already enabled for '${group}' group."
        return 0
    fi
    _koopa_h2 "Updating '${sudo_file}' to include '${group}'."
    local string
    string="%${group} ALL=(ALL) NOPASSWD: ALL"
    sudo sh -c "printf '%s\n' '$string' >> '${sudo_file}'"
    sudo chmod -v 0440 "$sudo_file"
    _koopa_success "Passwordless sudo enabled for '${group}' group."
    return 0
}

_koopa_enable_shell() { # {{{1
    # """
    # Enable shell.
    # @note Updated 2020-06-30.
    # """
    [ "$#" -gt 0 ] || return 1
    _koopa_has_sudo || return 0
    local cmd_name cmd_path etc_file
    cmd_name="${1:?}"
    cmd_path="$(_koopa_make_prefix)/bin/${cmd_name}"
    etc_file="/etc/shells"
    [ -f "$etc_file" ] || return 0
    _koopa_h2 "Updating '${etc_file}' to include '${cmd_path}'."
    if ! grep -q "$cmd_path" "$etc_file"
    then
        sudo sh -c "printf '%s\n' '${cmd_path}' >> '${etc_file}'"
    else
        _koopa_success "'${cmd_path}' already defined in '${etc_file}'."
    fi
    _koopa_note "Run 'chsh -s ${cmd_path} ${USER}' to change default shell."
    return 0
}

_koopa_find_user_profile() { # {{{1
    # """
    # Find current user's shell profile configuration file.
    # @note Updated 2020-06-30.
    # """
    [ "$#" -eq 0 ] || return 1
    local file shell
    shell="$(_koopa_shell)"
    case "$shell" in
        bash)
            file="${HOME}/.bashrc"
            ;;
        zsh)
            file="${HOME}/.zshrc"
            ;;
    esac
    _koopa_print "$file"
    return 0
}

_koopa_fix_pyenv_permissions() { # {{{1
    # """
    # Ensure Python pyenv shims have correct permissions.
    # @note Updated 2020-02-11.
    # """
    [ "$#" -eq 0 ] || return 1
    local pyenv_prefix
    pyenv_prefix="$(_koopa_pyenv_prefix)"
    [ -d "${pyenv_prefix}/shims" ] || return 0
    _koopa_h2 "Fixing Python pyenv shim permissions."
    _koopa_chmod -v 0777 "${pyenv_prefix}/shims"
    return 0
}

_koopa_fix_rbenv_permissions() { # {{{1
    # """
    # Ensure Ruby rbenv shims have correct permissions.
    # @note Updated 2020-02-11.
    # """
    [ "$#" -eq 0 ] || return 1
    local rbenv_prefix
    rbenv_prefix="$(_koopa_rbenv_prefix)"
    [ -d "${rbenv_prefix}/shims" ] || return 0
    _koopa_h2 "Fixing Ruby rbenv shim permissions."
    _koopa_chmod -v 0777 "${rbenv_prefix}/shims"
    return 0
}

_koopa_fix_zsh_permissions() { # {{{1
    # """
    # Fix ZSH permissions, to ensure compaudit checks pass.
    # @note Updated 2020-05-13.
    # """
    [ "$#" -eq 0 ] || return 1
    local cellar_prefix koopa_prefix make_prefix zsh_exe
    _koopa_h2 "Fixing Zsh permissions to pass 'compaudit' checks."
    koopa_prefix="$(_koopa_prefix)"
    _koopa_chmod -v g-w \
        "${koopa_prefix}/shell/zsh" \
        "${koopa_prefix}/shell/zsh/functions"
    _koopa_is_installed zsh || return 0
    zsh_exe="$(_koopa_which_realpath zsh)"
    make_prefix="$(_koopa_make_prefix)"
    if [ -d "${make_prefix}/share/zsh/site-functions" ]
    then
        if _koopa_str_match_regex "$zsh_exe" "^${make_prefix}"
        then
            _koopa_chmod -v g-w \
                "${make_prefix}/share/zsh" \
                "${make_prefix}/share/zsh/site-functions"
        fi
    fi
    cellar_prefix="$(_koopa_cellar_prefix)"
    if [ -d "$cellar_prefix" ]
    then
        if _koopa_str_match_regex "$zsh_exe" "^${cellar_prefix}"
        then
            _koopa_chmod -v g-w \
                "${cellar_prefix}/zsh/"*"/share/zsh" \
                "${cellar_prefix}/zsh/"*"/share/zsh/"* \
                "${cellar_prefix}/zsh/"*"/share/zsh/"*"/functions"
        fi
    fi
    return 0
}

_koopa_git_clone_docker() { # {{{1
    # """
    # Clone docker repo.
    # @note Updated 2020-02-19.
    # """
    [ "$#" -eq 0 ] || return 1
    _koopa_git_clone \
        "https://github.com/acidgenomics/docker.git" \
        "$(_koopa_docker_prefix)"
    return 0
}

_koopa_git_clone_docker_private() { # {{{1
    # """
    # Clone docker-private repo.
    # @note Updated 2020-07-03.
    # """
    [ "$#" -eq 0 ] || return 1
    _koopa_is_github_ssh_enabled || return 1
    _koopa_git_clone \
        "git@github.com:acidgenomics/docker-private.git" \
        "$(_koopa_docker_private_prefix)"
    return 0
}

_koopa_git_clone_dotfiles() { # {{{1
    # """
    # Clone dotfiles repo.
    # @note Updated 2020-02-19.
    # """
    [ "$#" -eq 0 ] || return 1
    _koopa_git_clone \
        "https://github.com/acidgenomics/dotfiles.git" \
        "$(_koopa_dotfiles_prefix)"
    return 0
}

_koopa_git_clone_dotfiles_private() { # {{{1
    # """
    # Clone dotfiles-private repo.
    # @note Updated 2020-06-30.
    # """
    [ "$#" -eq 0 ] || return 1
    _koopa_is_github_ssh_enabled || return 1
    _koopa_git_clone \
        "git@github.com:mjsteinbaugh/dotfiles-private.git" \
        "$(_koopa_dotfiles_private_prefix)"
    return 0
}

_koopa_git_clone_scripts_private() {
    # """
    # Clone private scripts.
    # @note Updated 2020-02-19.
    # """
    [ "$#" -eq 0 ] || return 1
    _koopa_is_github_ssh_enabled || return 1
    _koopa_git_clone \
        "git@github.com:mjsteinbaugh/scripts-private.git" \
        "$(_koopa_scripts_private_prefix)"
    return 0
}

_koopa_install_dotfiles() { # {{{1
    # """
    # Install dot files.
    # @note Updated 2020-06-30.
    # """
    [ "$#" -eq 0 ] || return 1
    local prefix script
    prefix="$(_koopa_dotfiles_prefix)"
    if [ ! -d "$prefix" ]
    then
        _koopa_git_clone_dotfiles
    fi
    script="${prefix}/install"
    _koopa_assert_is_file "$script"
    "$script"
    return 0
}

_koopa_install_dotfiles_private() { # {{{1
    # """
    # Install private dot files.
    # @note Updated 2020-02-19.
    # """
    [ "$#" -eq 0 ] || return 1
    # > _koopa_git_clone_dotfiles_private
    local prefix script
    prefix="$(_koopa_dotfiles_private_prefix)"
    if [ ! -d "$prefix" ]
    then
        _koopa_note "No private dotfiles at '${prefix}'."
        return 0
    fi
    script="${prefix}/install"
    _koopa_assert_is_file "$script"
    "$script"
    return 0
}

_koopa_install_mike() { # {{{1
    # """
    # Install additional Mike-specific config files.
    # @note Updated 2020-03-05.
    #
    # Note that these repos require SSH key to be set on GitHub.
    # """
    [ "$#" -eq 0 ] || return 1
    _koopa_git_clone_docker
    _koopa_git_clone_docker_private
    _koopa_git_clone_dotfiles
    _koopa_git_clone_dotfiles_private
    _koopa_git_clone_scripts_private
    _koopa_install_dotfiles
    _koopa_install_dotfiles_private
    return 0
}

_koopa_install_pip() { # {{{1
    # """
    # Install pip for Python.
    # @note Updated 2020-02-10.
    # """
    local file python
    python="${1:-python3}"
    if ! _koopa_is_installed "$python"
    then
        _koopa_warning "Python ('${python}') is not installed."
        return 1
    fi
    if _koopa_is_python_package_installed "pip" "$python"
    then
        _koopa_note "pip is already installed."
        return 0
    fi
    _koopa_h2 "Installing pip for Python '${python}'."
    file="get-pip.py"
    _koopa_download "https://bootstrap.pypa.io/${file}"
    "$python" "$file" --no-warn-script-location
    rm "$file"
    _koopa_install_success "pip"
    _koopa_restart
    return 0
}

_koopa_java_update_alternatives() {
    # """
    # Update Java alternatives.
    # @note Updated 2020-03-16.
    #
    # This step is intentionally skipped for non-admin installs, when calling
    # from 'install-openjdk' script.
    # """
    [ "$#" -gt 0 ] || return 1
    _koopa_is_shared_install || return 0
    _koopa_is_installed update-alternatives || return 0
    local prefix
    prefix="${1:?}"
    prefix="$(realpath "$prefix")"
    local priority
    priority="100"
    sudo rm -fv /var/lib/alternatives/java
    sudo update-alternatives --install \
        "/usr/bin/java" \
        "java" \
        "${prefix}/bin/java" \
        "$priority"
    sudo update-alternatives --set \
        "java" \
        "${prefix}/bin/java"
    sudo rm -fv /var/lib/alternatives/javac
    sudo update-alternatives --install \
        "/usr/bin/javac" \
        "javac" \
        "${prefix}/bin/javac" \
        "$priority"
    sudo update-alternatives --set \
        "javac" \
        "${prefix}/bin/javac"
    sudo rm -fv /var/lib/alternatives/jar
    sudo update-alternatives --install \
        "/usr/bin/jar" \
        "jar" \
        "${prefix}/bin/jar" \
        "$priority"
    sudo update-alternatives --set \
        "jar" \
        "${prefix}/bin/jar"
    update-alternatives --display java
    update-alternatives --display javac
    update-alternatives --display jar
    return 0
}

_koopa_link_docker() { # {{{1
    # """
    # Link Docker library onto data disk for VM.
    # @note Updated 2020-02-27.
    # """
    [ "$#" -eq 0 ] || return 1
    _koopa_is_installed docker || return 0
    # e.g. '/mnt/data01/n' to '/n' for AWS.
    local dd_link_prefix
    dd_link_prefix="$(_koopa_data_disk_link_prefix)"
    [ -d "$dd_link_prefix" ] || return 0
    _koopa_h2 "Updating Docker configuration."
    _koopa_assert_is_linux
    _koopa_assert_is_installed systemctl
    _koopa_note "Stopping Docker."
    sudo systemctl stop docker
    local lib_sys
    lib_sys="/var/lib/docker"
    local lib_n
    lib_n="${dd_link_prefix}/var/lib/docker"
    local os_id
    os_id="$(_koopa_os_id)"
    _koopa_note "Moving Docker lib from '${lib_sys}' to '${lib_n}'."
    local etc_source
    etc_source="$(_koopa_prefix)/os/${os_id}/etc/docker"
    if [ -d "$etc_source" ]
    then
        sudo mkdir -pv "/etc/docker"
        sudo ln -fnsv "${etc_source}"* "/etc/docker/."
    fi
    sudo rm -frv "$lib_sys"
    sudo mkdir -pv "$lib_n"
    sudo ln -fnsv "$lib_n" "$lib_sys"
    _koopa_note "Restarting Docker."
    sudo systemctl enable docker
    sudo systemctl start docker
    return 0
}

_koopa_remove_user_from_group() { # {{{1
    # """
    # Remove user from group.
    # @note Updated 2020-06-30.
    #
    # @examples
    # _koopa_remove_user_from_group "docker"
    # """
    [ "$#" -gt 0 ] || return 1
    _koopa_is_installed gpasswd sudo || return 1
    local group user
    group="${1:?}"
    user="${2:-${USER}}"
    sudo gpasswd --delete "$user" "$group"
}

_koopa_uninstall_dotfiles() { # {{{1
    # """
    # Uninstall dot files.
    # @note Updated 2020-02-19.
    # """
    [ "$#" -eq 0 ] || return 1
    local prefix script
    prefix="$(_koopa_dotfiles_prefix)"
    if [ ! -d "$prefix" ]
    then
        _koopa_note "No dotfiles at '${prefix}'."
        return 0
    fi
    script="${prefix}/uninstall"
    _koopa_assert_is_file "$script"
    "$script"
    return 0
}

_koopa_uninstall_dotfiles_private() { # {{{1
    # """
    # Uninstall private dot files.
    # @note Updated 2020-02-19.
    # """
    [ "$#" -eq 0 ] || return 1
    local prefix script
    prefix="$(_koopa_dotfiles_private_prefix)"
    if [ ! -d "$prefix" ]
    then
        _koopa_note "No private dotfiles at '${prefix}'."
        return 0
    fi
    script="${prefix}/uninstall"
    _koopa_assert_is_file "$script"
    "$script"
    return 0
}

_koopa_update_etc_profile_d() { # {{{1
    # """
    # Link shared 'zzz-koopa.sh' configuration file into '/etc/profile.d/'.
    # @note Updated 2020-05-09.
    # """
    [ "$#" -eq 0 ] || return 1
    _koopa_is_linux || return 0
    _koopa_is_shared_install || return 0
    local file
    file="/etc/profile.d/zzz-koopa.sh"
    # Early return if file exists and is not a symlink.
    # Previous verisons of koopa prior to 2020-05-09 created a symlink here.
    [ -f "$file" ] && [ ! -L "$file" ] && return 0
    sudo rm -fv "$file"
    local koopa_prefix
    koopa_prefix="$(_koopa_prefix)"
    local string
    read -r -d '' string << EOF || true
#!/bin/sh

# koopa shell
# https://koopa.acidgenomics.com/
# shellcheck source=/dev/null
. "${koopa_prefix}/activate"
EOF
    _koopa_sudo_write_string "$string" "$file"
}

_koopa_update_ldconfig() { # {{{1
    # """
    # Update dynamic linker (LD) configuration.
    # @note Updated 2020-06-30.
    # """
    [ "$#" -eq 0 ] || return 1
    _koopa_is_linux || return 0
    [ -d /etc/ld.so.conf.d ] || return 0
    _koopa_is_installed ldconfig || return 1
    local conf_source dest_file os_id prefix source_file
    os_id="$(_koopa_os_id)"
    prefix="$(_koopa_prefix)"
    conf_source="${prefix}/os/${os_id}/etc/ld.so.conf.d"
    [ -d "$conf_source" ] || return 0
    # Create symlinks with "koopa-" prefix.
    # Note that we're using shell globbing here.
    # https://unix.stackexchange.com/questions/218816
    _koopa_h2 "Updating ldconfig in '/etc/ld.so.conf.d/'."
    for source_file in "${conf_source}/"*".conf"
    do
        dest_file="/etc/ld.so.conf.d/koopa-$(basename "$source_file")"
        sudo ln -fnsv "$source_file" "$dest_file"
    done
    sudo ldconfig
    return 0
}

_koopa_update_lmod_config() { # {{{1
    # """
    # Link lmod configuration files in '/etc/profile.d/'.
    # @note Updated 2020-06-21.
    #
    # Need to check for this case:
    # ln: failed to create symbolic link '/etc/fish/conf.d/z00_lmod.fish':
    # No suchfile or directory
    # """
    [ "$#" -eq 0 ] || return 1
    _koopa_is_linux || return 0
    local etc_dir init_dir
    init_dir="$(_koopa_app_prefix)/lmod/apps/lmod/lmod/init"
    [ -d "$init_dir" ] || return 0
    _koopa_h2 "Updating Lmod init configuration."
    etc_dir="/etc/profile.d"
    sudo mkdir -pv "$etc_dir"
    # bash, zsh:
    sudo ln -fnsv "${init_dir}/profile" "${etc_dir}/z00_lmod.sh"
    # csh, tcsh:
    sudo ln -fnsv "${init_dir}/cshrc" "${etc_dir}/z00_lmod.csh"
    # fish:
    if _koopa_is_installed fish
    then
        etc_dir="/etc/fish/conf.d"
        sudo mkdir -pv "$etc_dir"
        sudo ln -fnsv "${init_dir}/profile.fish" "${etc_dir}/z00_lmod.fish"
    fi
    return 0
}

_koopa_update_xdg_config() { # {{{1
    # """
    # Update XDG configuration.
    # @note Updated 2020-06-30.
    #
    # Path: '~/.config/koopa'.
    # """
    [ "$#" -eq 0 ] || return 1
    # Consider allowing this for Docker images.
    # > _koopa_is_root && return 0
    local config_prefix koopa_prefix os_id
    # Harden against linked data disk failure and early return with warning.
    if [ ! -e "${HOME:-}" ]
    then
        _koopa_warning "HOME does not exist: '${HOME:-}'."
        return 0
    fi
    koopa_prefix="$(_koopa_prefix)"
    config_prefix="$(_koopa_config_prefix)"
    os_id="$(_koopa_os_id)"
    mkdir -p "$config_prefix"
    # Generate standard symlinks.
    _koopa_relink \
        "${koopa_prefix}" \
        "${config_prefix}/home"
    _koopa_relink \
        "${koopa_prefix}/activate" \
        "${config_prefix}/activate"
    _koopa_relink \
        "${koopa_prefix}/dotfiles" \
        "${config_prefix}/dotfiles"
    # Remove legacy config files.
    rm -fr \
        "${config_prefix}/R" \
        "${config_prefix}/rsync"
    return 0
}
