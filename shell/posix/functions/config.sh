#!/bin/sh
# shellcheck disable=SC2039

_koopa_add_config_link() {  # {{{1
    # """
    # Add a symlink into the koopa configuration directory.
    # @note Updated 2020-01-12.
    # """
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

_koopa_add_to_user_profile() {  # {{{1
    # """
    # Add koopa configuration to user profile.
    # @note Updated 2020-02-15.
    # """
    local target_file
    target_file="$(_koopa_find_user_profile)"
    local source_file
    source_file="$(_koopa_prefix)/shell/posix/include/profile.sh"
    _koopa_assert_is_file "$source_file"
    _koopa_h1 "Adding koopa activation to '${target_file}'."
    touch "$target_file"
    cat "$source_file" >> "$target_file"
    return 0
}

_koopa_add_user_to_etc_passwd() {  # {{{1
    # """
    # Any any type of user, including domain user to passwd file.
    # @note Updated 2020-02-28.
    #
    # Necessary for running 'chsh' with a Kerberos / Active Directory domain
    # account, on AWS or Azure for example.
    # """
    _koopa_assert_is_linux
    local passwd_file
    passwd_file="/etc/passwd"
    [ -f "$passwd_file" ] || return 1
    local user
    user="${1:-${USER:?}}"
    local user_string
    user_string="$(getent passwd "$user")"
    _koopa_h2 "Updating '${passwd_file}' to include '${user}'."
    if ! sudo grep -q "$user" "$passwd_file"
    then
        sudo sh -c "echo '${user_string}' >> ${passwd_file}"
    else
        _koopa_note "$user already defined in '${passwd_file}'."
    fi
    return 0
}

_koopa_add_user_to_group() {  # {{{1
    # """
    # Add user to group.
    # @note Updated 2020-02-11.
    #
    # Alternate approach:
    # > usermod -a -G group user
    #
    # @examples
    # _koopa_add_user_to_group "docker"
    # """
    _koopa_assert_is_installed gpasswd
    local group
    group="${1:?}"
    local user
    user="${2:-${USER}}"
    sudo gpasswd --add "$user" "$group"
}

_koopa_delete_dotfile() {  # {{{1
    # """
    # Delete a dot file.
    # @note Updated 2020-01-21.
    # """
    local name
    name="${1:?}"
    local filepath
    filepath="${HOME}/.${name}"
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

_koopa_enable_passwordless_sudo() {  # {{{1
    # """
    # Enable passwordless sudo access for all admin users.
    # @note Updated 2020-02-11.
    # """
    _koopa_is_linux || return 1
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
    sudo sh -c "echo '%${group} ALL=(ALL) NOPASSWD: ALL' >> ${sudo_file}"
    sudo chmod -v 0440 "$sudo_file"
    _koopa_success "Passwordless sudo enabled for '${group}' group."
    return 0
}

_koopa_enable_shell() {  # {{{1
    # """
    # Enable shell.
    # @note Updated 2020-02-14.
    # """
    local cmd
    cmd="${1:?}"
    cmd="$(_koopa_which "$cmd")"
    local etc_file
    etc_file="/etc/shells"
    _koopa_h2 "Updating '${etc_file}' to include '${cmd}'."
    if ! grep -q "$cmd" "$etc_file"
    then
        sudo sh -c "echo ${cmd} >> ${etc_file}"
    else
        _koopa_success "'${cmd}' already defined in '${etc_file}'."
    fi
    _koopa_note "Run 'chsh -s ${cmd} ${USER}' to change default shell."
    return 0
}

_koopa_find_user_profile() {  # {{{1
    # """
    # Find current user's shell profile configuration file.
    # @note Updated 2020-02-15.
    # """
    local shell
    shell="$(_koopa_shell)"
    local file
    case "$shell" in
        bash)
            file="${HOME}/.bashrc"
            ;;
        zsh)
            file="${HOME}/.zshrc"
            ;;
    esac
    echo "$file"
    return 0
}

_koopa_fix_pyenv_permissions() {  # {{{1
    # """
    # Ensure Python pyenv shims have correct permissions.
    # @note Updated 2020-02-11.
    # """
    local pyenv_prefix
    pyenv_prefix="$(_koopa_pyenv_prefix)"
    [ -d "${pyenv_prefix}/shims" ] || return 0
    _koopa_h2 "Fixing Python pyenv shim permissions."
    _koopa_chmod -v 0777 "${pyenv_prefix}/shims"
    return 0
}

_koopa_fix_rbenv_permissions() {  # {{{1
    # """
    # Ensure Ruby rbenv shims have correct permissions.
    # @note Updated 2020-02-11.
    # """
    local rbenv_prefix
    rbenv_prefix="$(_koopa_rbenv_prefix)"
    [ -d "${rbenv_prefix}/shims" ] || return 0
    _koopa_h2 "Fixing Ruby rbenv shim permissions."
    _koopa_chmod -v 0777 "${rbenv_prefix}/shims"
    return 0
}

_koopa_fix_zsh_permissions() {  # {{{1
    # """
    # Fix ZSH permissions, to ensure compaudit checks pass.
    # @note Updated 2020-02-11.
    # """
    _koopa_h2 "Fixing Zsh permissions to pass 'compaudit' checks."
    local koopa_prefix
    koopa_prefix="$(_koopa_prefix)"
    _koopa_chmod -v g-w \
        "${koopa_prefix}/shell/zsh" \
        "${koopa_prefix}/shell/zsh/functions"
    _koopa_is_installed zsh || return 0
    local make_prefix
    make_prefix="$(_koopa_make_prefix)"
    local cellar_prefix
    cellar_prefix="$(_koopa_cellar_prefix)"
    local zsh_exe
    zsh_exe="$(_koopa_which_realpath zsh)"
    if _koopa_is_matching_regex "$zsh_exe" "^${make_prefix}"
    then
        _koopa_chmod -v g-w \
            "${make_prefix}/share/zsh" \
            "${make_prefix}/share/zsh/site-functions"
    fi
    if _koopa_is_matching_regex "$zsh_exe" "^${cellar_prefix}"
    then
        _koopa_chmod -v g-w \
            "${cellar_prefix}/zsh/"*"/share/zsh" \
            "${cellar_prefix}/zsh/"*"/share/zsh/"* \
            "${cellar_prefix}/zsh/"*"/share/zsh/"*"/functions"
    fi
    return 0
}

_koopa_git_clone_docker() {
    # """
    # Clone docker repo.
    # @note Updated 2020-02-19.
    # """
    _koopa_git_clone \
        "https://github.com/acidgenomics/docker.git" \
        "$(_koopa_docker_prefix)"
    return 0
}

_koopa_git_clone_dotfiles() {  # {{{1
    # """
    # Clone dotfiles repo.
    # @note Updated 2020-02-19.
    # """
    _koopa_git_clone \
        "https://github.com/mjsteinbaugh/dotfiles.git" \
        "$(_koopa_dotfiles_prefix)"
    return 0
}

_koopa_git_clone_dotfiles_private() {  # {{{1
    # """
    # Clone dotfiles-private repo.
    # @note Updated 2020-02-19.
    # """
    _koopa_assert_is_github_ssh_enabled
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
    _koopa_assert_is_github_ssh_enabled
    _koopa_git_clone \
        "git@github.com:mjsteinbaugh/scripts-private.git" \
        "$(_koopa_scripts_private_prefix)"  
    return 0
}

_koopa_install_dotfiles() {  # {{{1
    # """
    # Install dot files.
    # @note Updated 2020-02-19.
    # """
    local prefix
    prefix="$(_koopa_dotfiles_prefix)"
    if [ ! -d "$prefix" ]
    then
        _koopa_note "No dotfiles at '${prefix}'."
        return 0
    fi
    local script
    script="${prefix}/install"
    _koopa_assert_is_file "$script"
    "$script"
    return 0
}

_koopa_install_dotfiles_private() {  # {{{1
    # """
    # Install private dot files.
    # @note Updated 2020-02-19.
    # """
    # > _koopa_git_clone_dotfiles_private
    local prefix
    prefix="$(_koopa_dotfiles_private_prefix)"
    if [ ! -d "$prefix" ]
    then
        _koopa_note "No private dotfiles at '${prefix}'."
        return 0
    fi
    local script
    script="${prefix}/install"
    _koopa_assert_is_file "$script"
    "$script"
    return 0
}

_koopa_install_mike() {  # {{{1
    # """
    # Install additional Mike-specific config files.
    # @note Updated 2020-02-19.
    #
    # Note that these repos require SSH key to be set on GitHub.
    # """
    _koopa_git_clone_docker
    _koopa_git_clone_dotfiles
    _koopa_git_clone_dotfiles_private
    _koopa_git_clone_scripts_private
    _koopa_install_dotfiles
    _koopa_install_dotfiles_private
    return 0
}

_koopa_install_pip() {  # {{{1
    # """
    # Install pip for Python.
    # @note Updated 2020-02-10.
    # """
    local python
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
    local file
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
    # @note Updated 2020-02-28.
    # """
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

_koopa_link_docker() {  # {{{1
    # """
    # Link Docker library onto data disk for VM.
    # @note Updated 2020-02-27.
    # """
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

_koopa_link_r_etc() {  # {{{1
    # """
    # Link R config files inside 'etc/'.
    # @note Updated 2020-03-01.
    #
    # Applies to 'Renviron.site' and 'Rprofile.site' files.
    # Note that on macOS, we don't want to copy the 'Makevars' file here.
    # """
    _koopa_is_installed R || return 0

    local r_home
    r_home="$(_koopa_r_home)"
    [ -d "$r_home" ] || return 1

    local r_etc_target
    r_etc_target="${r_home}/etc"
    [ -d "$r_etc_target" ] || return 1

    # Don't overwrite existing site configuration files.
    # This applies primarily to Bioconductor Docker images.
    [ -f "${r_etc_target}/Renviron.site" ] &&
        [ -f "${r_etc_target}/Rprofile.site" ] &&
        return 0

    local koopa_prefix
    koopa_prefix="$(_koopa_prefix)"

    local os_id
    os_id="$(_koopa_os_id)"

    local r_etc_source
    r_etc_source="${koopa_prefix}/os/${os_id}/etc/R"
    [ -d "$r_etc_source" ] || return 1

    _koopa_h2 "Updating '${r_etc_target}' from '${r_etc_source}'."

    # Don't overwrite the Bioconductor Docker config.
    _koopa_ln "${r_etc_source}/"*".site" "${r_home}/etc/."

    return 0
}

_koopa_link_r_site_library() {  # {{{1
    # """
    # Link R site library.
    # @note Updated 2020-03-01.
    # """
    _koopa_is_installed R || return 0

    local r_home
    r_home="$(_koopa_r_home)"
    [ -d "$r_home" ] || return 1

    local version
    version="$(_koopa_r_version)"

    local minor_version
    minor_version="$(_koopa_minor_version "$version")"

    local app_prefix
    app_prefix="$(_koopa_app_prefix)"

    local lib_source
    lib_source="${app_prefix}/r/${minor_version}/site-library"

    local lib_target
    lib_target="${r_home}/site-library"

    _koopa_h2 "Creating site library at '${r_home}'."

    _koopa_mkdir "$lib_source"
    _koopa_ln "$lib_source" "$lib_target"

    # Debian R defaults to '/usr/local/lib/R/site-library' even though R_HOME
    # is '/usr/lib/R'. Ensure we link here also.
    if [[ -d "/usr/local/lib/R" ]]
    then
        _koopa_ln "$lib_source" "/usr/local/lib/R/site-library"
    fi

    return 0
}

_koopa_remove_user_from_group() {  # {{{1
    # """
    # Remove user from group.
    # @note Updated 2020-02-11.
    #
    # @examples
    # _koopa_remove_user_from_group "docker"
    # """
    _koopa_assert_is_installed gpasswd
    local group
    group="${1:?}"
    local user
    user="${2:-${USER}}"
    sudo gpasswd --delete "$user" "$group"
}

_koopa_uninstall_dotfiles() {  # {{{1
    # """
    # Uninstall dot files.
    # @note Updated 2020-02-19.
    # """
    local prefix
    prefix="$(_koopa_dotfiles_prefix)"
    if [ ! -d "$prefix" ]
    then
        _koopa_note "No dotfiles at '${prefix}'."
        return 0
    fi
    local script
    script="${prefix}/uninstall"
    _koopa_assert_is_file "$script"
    "$script"
    return 0
}

_koopa_uninstall_dotfiles_private() {  # {{{1
    # """
    # Uninstall private dot files.
    # @note Updated 2020-02-19.
    # """
    local prefix
    prefix="$(_koopa_dotfiles_private_prefix)"
    if [ ! -d "$prefix" ]
    then
        _koopa_note "No private dotfiles at '${prefix}'."
        return 0
    fi
    local script
    script="${prefix}/uninstall"
    _koopa_assert_is_file "$script"
    "$script"
    return 0
}

_koopa_update_etc_profile_d() {  # {{{1
    # """
    # Link shared 'zzz-koopa.sh' configuration file into '/etc/profile.d/'.
    # @note Updated 2020-02-15.
    # """
    _koopa_is_shared_install || return 0
    _koopa_is_linux || return 0
    local symlink
    symlink="/etc/profile.d/zzz-koopa.sh"
    # Early return if link already exists.
    [ -L "$symlink" ] && return 0
    _koopa_h2 "Adding '${symlink}'."
    sudo rm -fv "/etc/profile.d/koopa.sh"
    sudo ln -fnsv \
        "$(_koopa_prefix)/os/linux/etc/profile.d/zzz-koopa.sh" \
        "$symlink"
    return 0
}

_koopa_update_ldconfig() {  # {{{1
    # """
    # Update dynamic linker (LD) configuration.
    # @note Updated 2020-01-23.
    # """
    _koopa_is_linux || return 0
    [ -d /etc/ld.so.conf.d ] || return 0
    _koopa_assert_is_installed ldconfig
    local os_id
    os_id="$(_koopa_os_id)"
    local prefix
    prefix="$(_koopa_prefix)"
    local conf_source
    conf_source="${prefix}/os/${os_id}/etc/ld.so.conf.d"
    [ -d "$conf_source" ] || return 0
    # Create symlinks with "koopa-" prefix.
    # Note that we're using shell globbing here.
    # https://unix.stackexchange.com/questions/218816
    _koopa_h2 "Updating ldconfig in '/etc/ld.so.conf.d/'."
    local source_file
    local dest_file
    for source_file in "${conf_source}/"*".conf"
    do
        dest_file="/etc/ld.so.conf.d/koopa-$(basename "$source_file")"
        sudo ln -fns "$source_file" "$dest_file"
    done
    sudo ldconfig
    return 0
}

_koopa_update_lmod_config() {  # {{{1
    # """
    # Link lmod configuration files in '/etc/profile.d/'.
    # @note Updated 2020-02-07.
    #
    # Need to check for this case:
    # ln: failed to create symbolic link '/etc/fish/conf.d/z00_lmod.fish':
    # No suchfile or directory
    # """
    _koopa_is_linux || return 0
    _koopa_h2 "Updating Lmod init configuration."
    local init_dir
    init_dir="$(_koopa_app_prefix)/lmod/apps/lmod/lmod/init"
    [ -d "$init_dir" ] || return 0
    local etc_dir
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

_koopa_update_r_config() {  # {{{1
    # """
    # Add shared R configuration symlinks in '${R_HOME}/etc'.
    # @note Updated 2019-12-16.
    # """
    _koopa_is_installed R || return 0
    local r_home
    r_home="$(_koopa_r_home)"
    _koopa_link_r_etc
    _koopa_link_r_site_library
    _koopa_set_permissions --recursive "$r_home"
    _koopa_r_javareconf
    return 0
}

_koopa_update_r_config_macos() {  # {{{1
    # """
    # Update R config on macOS.
    # @note Updated 2019-10-31.
    #
    # Need to include Makevars to build packages from source.
    # """
    mkdir -pv "${HOME}/.R"
    ln -fnsv "/usr/local/koopa/os/macos/etc/R/Makevars" "${HOME}/.R/."
    return 0
}

_koopa_update_xdg_config() {  # {{{1
    # """
    # Update XDG configuration.
    # @note Updated 2020-02-15.
    #
    # Path: '~/.config/koopa'.
    # """
    # Allowing this, for Docker images.
    # > _koopa_is_root && return 0
    local koopa_prefix
    koopa_prefix="$(_koopa_prefix)"
    local config_prefix
    config_prefix="$(_koopa_config_prefix)"
    local os_id
    os_id="$(_koopa_os_id)"
    mkdir -p "$config_prefix"
    _koopa_relink "${koopa_prefix}" "${config_prefix}/home"
    _koopa_relink "${koopa_prefix}/activate" "${config_prefix}/activate"
    _koopa_relink "${koopa_prefix}/dotfiles" "${config_prefix}/dotfiles"
    if [ -d "${koopa_prefix}/os/${os_id}" ]
    then
        _koopa_relink "${koopa_prefix}/os/${os_id}/etc/R" "${config_prefix}/R"
    fi
    return 0
}
