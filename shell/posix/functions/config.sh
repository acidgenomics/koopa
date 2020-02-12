#!/bin/sh
# shellcheck disable=SC2039

_koopa_chgrp() {                                                          # {{{1
    # """
    # chgrp with dynamic sudo handling.
    # Updated 2020-01-24.
    # """
    if _koopa_is_shared_install
    then
        _koopa_assert_has_sudo
        sudo chgrp "$@"
    else
        chgrp "$@"
    fi
    return 0
}

_koopa_chmod() {                                                          # {{{1
    # """
    # chmod with dynamic sudo handling.
    # Updated 2020-01-24.
    # """
    if _koopa_is_shared_install
    then
        _koopa_assert_has_sudo
        sudo chmod "$@"
    else
        chmod "$@"
    fi
    return 0
}

_koopa_chown() {                                                          # {{{1
    # """
    # chown with dynamic sudo handling.
    # Updated 2020-01-24.
    # """
    if _koopa_is_shared_install
    then
        _koopa_assert_has_sudo
        sudo chown "$@"
    else
        chown "$@"
    fi
    return 0
}

_koopa_mkdir() {                                                          # {{{1
    # """
    # mkdir with dynamic sudo handling.
    # Updated 2020-02-06.
    # """
    if _koopa_is_shared_install
    then
        _koopa_assert_has_sudo
        sudo mkdir -p "$@"
    else
        mkdir -p "$@"
    fi
    return 0
}

_koopa_rm() {                                                             # {{{1
    # """
    # Remove files/directories without dealing with permissions.
    # Updated 2020-02-06.
    # """
    if _koopa_is_shared_install
    then
        _koopa_assert_has_sudo
        sudo rm -fr "$@"
    else
        rm -fr "$@"
    fi
    return 0
}



_koopa_prefix_chgrp() {                                                   # {{{1
    # """
    # Set group for target prefix(es).
    # Updated 2020-01-24.
    # """
    _koopa_chgrp -R "$(_koopa_group)" "$@"
    return 0
}

_koopa_prefix_chmod() {                                                   # {{{1
    # """
    # Set file permissions for target prefix(es).
    # Updated 2020-01-24.
    #
    # This sets group write access by default for shared install, which is
    # useful so we don't have to constantly switch to root for admin.
    # """
    if _koopa_is_shared_install
    then
        _koopa_assert_has_sudo
        sudo chmod -R u+rw,g+rw "$@"
    else
        chmod -R u+rw,g+r,g-w "$@"
    fi
    return 0
}

_koopa_prefix_chown() {                                                   # {{{1
    # """
    # Set ownership (user and group) for target prefix(es).
    # Updated 2020-01-24.
    # """
    local group
    group="$(_koopa_group)"
    if _koopa_is_shared_install
    then
        _koopa_assert_has_sudo
        sudo chown -Rh "root:${group}" "$@"
    else
        chown -Rh "${USER:?}:${group}" "$@"
    fi
    return 0
}

_koopa_prefix_chown_user() {                                              # {{{1
    # """
    # Set ownership to current user for target prefix(es).
    # Updated 2020-01-17.
    # """
    local user
    user="${USER:?}"
    local group
    group="$(_koopa_group)"
    if _koopa_is_shared_install
    then
        _koopa_assert_has_sudo
        sudo chown -Rh "${user}:${group}" "$@"
    else
        chown -Rh "${user}:${group}" "$@"
    fi
    return 0
}

_koopa_prefix_mkdir() {                                                   # {{{1
    # """
    # Make directory at target prefix, only if it doesn't exist.
    # Updated 2020-01-24.
    #
    # Note that the main difference with '_koopa_mkdir' is the extra assert
    # check to look if directory already exists here.
    # """
    local prefix
    prefix="${1:?}"
    _koopa_assert_is_not_dir "$prefix"
    _koopa_mkdir "$prefix"
    _koopa_set_permissions "$prefix"
    return 0
}



_koopa_set_permissions() {                                                # {{{1
    # """
    # Set permissions on target prefix(es).
    # Updated 2020-01-24.
    # """
    _koopa_prefix_chown "$@"
    _koopa_prefix_chmod "$@"
    return 0
}

_koopa_set_permissions_user() {                                           # {{{1
    # """
    # Set permissions on target prefix(es) to current user.
    # Updated 2020-01-24.
    # """
    _koopa_prefix_chown_user "$@"
    _koopa_prefix_chmod "$@"
    return 0
}

_koopa_set_sticky_group() {                                               # {{{1
    # """
    # Set sticky group bit for target prefix(es).
    # Updated 2020-01-24.
    # """
    _koopa_chmod g+s "$@"
    return 0
}



_koopa_add_user_to_etc_passwd() {                                         # {{{1
    # """
    # Any any type of user, including domain user to passwd file.
    # Updated 2020-01-21.
    #
    # Necessary for running 'chsh' with a Kerberos / Active Directory domain
    # account, on AWS or Azure for example.
    # """
    _koopa_assert_is_linux
    local passwd_file
    passwd_file="/etc/passwd"
    [ -f "$passwd_file" ] || return 1
    local user
    user="${USER:?}"
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

_koopa_enable_passwordless_sudo() {                                       # {{{1
    # """
    # Enable passwordless sudo access for all admin users.
    # Updated 2020-02-11.
    # """
    _koopa_is_linux || return 1
    _koopa_is_root && return 0
    _koopa_has_sudo || return 1
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

_koopa_enable_shell() {                                                  # {{{1
    # """
    # Enable shell.
    # Updated 2020-02-11.
    # """
    _koopa_assert_has_sudo
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



_koopa_add_user_to_group() {                                              # {{{1
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
    _koopa_assert_has_sudo
    _koopa_assert_is_installed gpasswd
    local group
    group="${1:?}"
    local user
    user="${2:-${USER}}"
    sudo gpasswd --add "$user" "$group"
}

_koopa_remove_user_from_group() {                                         # {{{1
    # """
    # Remove user from group.
    # @note Updated 2020-02-11.
    #
    # @examples
    # _koopa_remove_user_from_group "docker"
    # """
    _koopa_assert_has_sudo
    _koopa_assert_is_installed gpasswd
    local group
    group="${1:?}"
    local user
    user="${2:-${USER}}"
    sudo gpasswd --delete "$user" "$group"
}



_koopa_fix_pyenv_permissions() {                                          # {{{1
    # """
    # Ensure Python pyenv shims have correct permissions.
    # Updated 2020-02-11.
    # """
    local pyenv_prefix
    pyenv_prefix="$(_koopa_pyenv_prefix)"
    [ -d "${pyenv_prefix}/shims" ] || return 0
    _koopa_h2 "Fixing Python pyenv shim permissions."
    _koopa_chmod -v 0777 "${pyenv_prefix}/shims"
    return 0
}

_koopa_fix_rbenv_permissions() {                                          # {{{1
    # """
    # Ensure Ruby rbenv shims have correct permissions.
    # Updated 2020-02-11.
    # """
    local rbenv_prefix
    rbenv_prefix="$(_koopa_rbenv_prefix)"
    [ -d "${rbenv_prefix}/shims" ] || return 0
    _koopa_h2 "Fixing Ruby rbenv shim permissions."
    _koopa_chmod -v 0777 "${rbenv_prefix}/shims"
    return 0
}

_koopa_fix_zsh_permissions() {                                            # {{{1
    # """
    # Fix ZSH permissions, to ensure compaudit checks pass.
    # Updated 2020-02-11.
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

_koopa_link_docker() {                                                    # {{{1
    # """
    # Link Docker library onto data disk for VM.
    # Updated 2020-01-22.
    # """
    _koopa_is_installed docker || return 0
    _koopa_assert_is_installed systemctl
    [ -d "/n" ] || return 0
    _koopa_assert_has_sudo
    _koopa_assert_is_linux
    _koopa_h2 "Updating Docker configuration."
    _koopa_note "Stopping Docker."
    sudo systemctl stop docker
    local lib_sys
    lib_sys="/var/lib/docker"
    local lib_n
    lib_n="/n/var/lib/docker"
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

_koopa_link_r_etc() {                                                     # {{{1
    # """
    # Link R config files inside 'etc/'.
    # Updated 2020-01-21.
    #
    # Applies to 'Renviron.site' and 'Rprofile.site' files.
    # Note that on macOS, we don't want to copy the 'Makevars' file here.
    # """
    _koopa_assert_has_sudo
    local r_home
    r_home="$(_koopa_r_home)"
    local koopa_prefix
    koopa_prefix="$(_koopa_prefix)"
    local os_id
    os_id="$(_koopa_os_id)"
    local r_etc_source
    r_etc_source="${koopa_prefix}/os/${os_id}/etc/R"
    if [ ! -d "$r_etc_source" ]
    then
        _koopa_note "Source files missing: '${r_etc_source}'."
        return 0
    fi
    _koopa_h2 "Updating '${r_home}'."
    sudo ln -fnsv "${r_etc_source}/"*".site" "${r_home}/etc/."
    return 0
}

_koopa_link_r_site_library() {                                            # {{{1
    # """
    # Link R site library.
    # Updated 2020-01-14.
    # """
    _koopa_assert_has_sudo
    local r_home
    r_home="$(_koopa_r_home)"
    local version
    version="$(_koopa_r_version)"
    local minor_version
    minor_version="$(_koopa_minor_version "$version")"
    local app_prefix
    app_prefix="$(_koopa_app_prefix)"
    _koopa_h2 "Creating site library at '${r_home}'."
    local lib_source
    lib_source="${app_prefix}/r/${minor_version}/site-library"
    local lib_target
    lib_target="${r_home}/site-library"
    sudo rm -frv "$lib_target"
    sudo mkdir -pv "$lib_source"
    sudo ln -fnsv "$lib_source" "$lib_target"
    if _koopa_is_debian
    then
        # Link the site-library in '/usr/lib/R' instead.
        sudo rm -frv /usr/local/lib/R
    fi
    return 0
}

_koopa_make_build_string() {                                              # {{{1
    # """
    # OS build string for 'make' configuration.
    # Updated 2020-01-13.
    #
    # Use this for 'configure --build' flag.
    #
    # This function will distinguish between RedHat, Amazon, and other distros
    # instead of just returning "linux". Note that we're substituting "redhat"
    # instead of "rhel" here, when applicable.
    #
    # - AWS:    x86_64-amzn-linux-gnu
    # - macOS: x86_64-darwin15.6.0
    # - RedHat: x86_64-redhat-linux-gnu
    # """
    local mach
    mach="$(uname -m)"
    local os_type
    os_type="${OSTYPE:?}"
    local os_id
    local string
    if _koopa_is_macos
    then
        string="${mach}-${os_type}"
    else
        os_id="$(_koopa_os_id)"
        if echo "$os_id" | grep -q "rhel"
        then
            os_id="redhat"
        fi
        string="${mach}-${os_id}-${os_type}"
    fi
    echo "$string"
}

_koopa_update_ldconfig() {                                                # {{{1
    # """
    # Update dynamic linker (LD) configuration.
    # Updated 2020-01-23.
    # """
    _koopa_is_linux || return 0
    _koopa_has_sudo || return 0
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

_koopa_update_lmod_config() {                                             # {{{1
    # """
    # Link lmod configuration files in '/etc/profile.d/'.
    # @note Updated 2020-02-07.
    #
    # Need to check for this case:
    # ln: failed to create symbolic link '/etc/fish/conf.d/z00_lmod.fish':
    # No suchfile or directory
    # """
    _koopa_is_linux || return 0
    _koopa_has_sudo || return 0

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

_koopa_update_profile() {                                                 # {{{1
    # """
    # Link shared 'zzz-koopa.sh' configuration file into '/etc/profile.d/'.
    # Updated 2020-01-21.
    # """
    _koopa_is_shared_install || return 0
    _koopa_is_linux || return 0
    _koopa_has_sudo || return 0
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

_koopa_update_r_config() {                                                # {{{1
    # """
    # Add shared R configuration symlinks in '${R_HOME}/etc'.
    # Updated 2019-12-16.
    # """
    _koopa_has_sudo || return 0
    _koopa_is_installed R || return 0
    local r_home
    r_home="$(_koopa_r_home)"
    _koopa_link_r_etc
    _koopa_link_r_site_library
    _koopa_set_permissions "$r_home"
    _koopa_r_javareconf
    return 0
}

_koopa_update_r_config_macos() {                                          # {{{1
    # """
    # Update R config on macOS.
    # Updated 2019-10-31.
    #
    # Need to include Makevars to build packages from source.
    # """
    mkdir -pv "${HOME}/.R"
    ln -fnsv "/usr/local/koopa/os/macos/etc/R/Makevars" "${HOME}/.R/."
    return 0
}

_koopa_update_xdg_config() {                                              # {{{1
    # """
    # Update XDG configuration.
    # Updated 2020-01-09.
    #
    # Path: '~/.config/koopa'.
    # """
    _koopa_is_root && return 0
    local config_dir
    config_dir="$(_koopa_config_prefix)"
    local prefix_dir
    prefix_dir="$(_koopa_prefix)"
    local os_id
    os_id="$(_koopa_os_id)"
    mkdir -p "$config_dir"
    _koopa_relink "${prefix_dir}" "${config_dir}/home"
    _koopa_relink "${prefix_dir}/activate" "${config_dir}/activate"
    if [ -d "${prefix_dir}/os/${os_id}" ]
    then
        _koopa_relink "${prefix_dir}/os/${os_id}/etc/R" "${config_dir}/R"
    fi
    return 0
}
