#!/bin/sh
# shellcheck disable=SC2039

_koopa_chgrp() {                                                          # {{{1
    # """
    # Set group only (keep current user).
    # Updated 2020-01-16.
    # """
    local prefix
    prefix="${1:?}"
    local group
    group="$(_koopa_group)"
    if _koopa_is_shared_install
    then
        _koopa_assert_has_sudo
        sudo chgrp -R "$group" "$prefix"
    else
        chmod -R "$group" "$prefix"
    fi
    return 0
}

_koopa_chmod() {                                                          # {{{1
    # """
    # Set file modification permissions on the target prefix.
    # Updated 2020-01-16.
    #
    # This sets group write access by default for shared install, which is
    # useful so we don't have to constantly switch to root for admin.
    # """
    local prefix
    prefix="${1:?}"
    if _koopa_is_shared_install
    then
        _koopa_assert_has_sudo
        sudo chmod -R g+w "$prefix"
    else
        chmod -R g-w "$prefix"
    fi
    return 0
}

_koopa_chown() {                                                          # {{{1
    # """
    # Set ownership (user and group) on the target prefix.
    # Updated 2020-01-16.
    # """
    local prefix
    prefix="${1:?}"
    local group
    group="$(_koopa_group)"
    if _koopa_is_shared_install
    then
        _koopa_assert_has_sudo
        sudo chown -Rh "root:${group}" "$prefix"
    else
        chown -Rh "${USER:?}:${group}" "$prefix"
    fi
    return 0
}

_koopa_chown_user() {                                                     # {{{1
    # """
    # Set ownership to current user.
    # Updated 2020-01-17.
    # """
    local prefix
    prefix="${1:?}"
    local user
    user="${USER:?}"
    local group
    group="$(_koopa_group)"
    if _koopa_is_shared_install
    then
        _koopa_assert_has_sudo
        sudo chown -Rh "${user}:${group}" "$prefix"
    else
        chown -Rh "${user}:${group}" "$prefix"
    fi
    return 0
}

_koopa_mkdir() {                                                          # {{{1
    # """
    # Make directory at target prefix.
    # Updated 2020-01-16.
    #
    # Errors intentionally if the directory already exists.
    # Sets correct group and write permissions automatically.
    # """
    local prefix
    prefix="${1:?}"
    if _koopa_is_shared_install
    then
        _koopa_assert_has_sudo
        sudo mkdir -pv "$prefix"
    else
        mkdir -pv "$prefix"
    fi
    _koopa_set_permissions "$prefix"
    return 0
}

_koopa_set_permissions() {                                                # {{{1
    # """
    # Set permissions on a koopa-related directory prefix.
    # Updated 2020-01-16.
    # """
    local prefix
    prefix="${1:?}"
    _koopa_chown "$prefix"
    _koopa_chmod "$prefix"
    return 0
}

_koopa_set_permissions_user() {                                           # {{{1
    # """
    # Set permissions on a target prefix to current user.
    # Updated 2020-01-17.
    # """
    local prefix
    prefix="${1:?}"
    _koopa_chown_user "$prefix"
    _koopa_chmod "$prefix"
    return 0
}

_koopa_set_sticky_group() {                                               # {{{1
    # """
    # Set sticky group bit.
    # Updated 2020-01-16.
    # """
    local prefix
    prefix="${1:?}"
    if _koopa_is_shared_install
    then
        _koopa_assert_has_sudo
        sudo chmod g+s "$prefix"
    else
        chmod g+s "$prefix"
    fi
    return 0
}

_koopa_prefix_mkdir() {                                                   # {{{1
    # """
    # Make directory at target prefix, only if it doesn't exist.
    # Updated 2020-01-16.
    # """
    local prefix
    prefix="${1:?}"
    _koopa_assert_is_not_dir "$prefix"
    _koopa_mkdir "$prefix"
    return 0
}



_koopa_add_user_to_etc_passwd() {                                         # {{{1
    # """
    # Any any type of user, including domain user to passwd file.
    # Updated 2020-01-15.
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
    _koopa_message "Updating '${passwd_file}' to include '${user}'."
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
    # Updated 2020-01-16.
    # """
    _koopa_assert_is_linux
    _koopa_assert_has_sudo
    local group
    group="$(_koopa_group)"
    local sudo_file
    sudo_file="/etc/sudoers.d/sudo"
    _koopa_message "Updating '${sudo_file}' to include '${group}'."
    sudo touch "$sudo_file"
    sudo chmod -v 0440 "$sudo_file"
    if sudo grep -q "$group" "$sudo_file"
    then
        _koopa_success "Passwordless sudo already enabled for '${group}'."
        return 0
    fi
    sudo sh -c "echo '%${group} ALL=(ALL) NOPASSWD: ALL' >> ${sudo_file}"
    _koopa_success "Passwordless sudo enabled for '${group}'."
    return 0
}

_koopa_link_docker() {                                                    # {{{1
    # """
    # Link Docker library onto data disk for VM.
    # Updated 2020-01-14.
    # """
    _koopa_is_installed docker || return 0
    [ -d "/n" ] || return 0
    _koopa_assert_has_sudo
    _koopa_assert_is_linux
    _koopa_message "Updating Docker configuration."
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
        sudo ln -fnsv "$etc_source"* "/etc/docker/."
    fi
    sudo systemctl stop docker
    sudo rm -frv "$lib_sys"
    sudo mkdir -pv "$lib_n"
    sudo ln -fnsv "$lib_n" "$lib_sys"
    sudo systemctl enable docker
    sudo systemctl start docker
    return 0
}

_koopa_link_r_etc() {                                                     # {{{1
    # """
    # Link R config files inside 'etc/'.
    # Updated 2020-01-14.
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
    _koopa_message "Updating '${r_home}'."
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
    version="$(_koopa_current_version r)"
    local minor_version
    minor_version="$(_koopa_minor_version "$version")"
    local app_prefix
    app_prefix="$(_koopa_app_prefix)"
    _koopa_message "Creating site library at '${r_home}'."
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
    # Updated 2019-12-16.
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
    _koopa_message "Updating ldconfig in '/etc/ld.so.conf.d/'."
    local source_file
    local dest_file
    for source_file in "${conf_source}/"*".conf"
    do
        dest_file="/etc/ld.so.conf.d/koopa-$(basename "$source_file")"
        sudo ln -fnsv "$source_file" "$dest_file"
    done
    sudo ldconfig
    return 0
}

_koopa_update_lmod_config() {                                             # {{{1
    # """
    # Link lmod configuration files in '/etc/profile.d/'.
    # Updated 2019-11-26.
    # """
    _koopa_is_linux || return 0
    _koopa_has_sudo || return 0
    _koopa_message "Updating Lmod configuration in '/etc/profile.d/'."
    local init_dir
    init_dir="$(_koopa_app_prefix)/lmod/apps/lmod/lmod/init"
    [ -d "$init_dir" ] || return 0
    sudo ln -fnsv "${init_dir}/cshrc" "/etc/profile.d/z00_lmod.csh"
    sudo ln -fnsv "${init_dir}/profile" "/etc/profile.d/z00_lmod.sh"
    return 0
}

_koopa_update_profile() {                                                 # {{{1
    # """
    # Link shared 'zzz-koopa.sh' configuration file into '/etc/profile.d/'.
    # Updated 2020-01-11.
    # """
    _koopa_is_shared_install || return 0
    _koopa_is_linux || return 0
    _koopa_has_sudo || return 0
    local symlink
    symlink="/etc/profile.d/zzz-koopa.sh"
    # Early return if link already exists.
    [ -L "$symlink" ] && return 0
    _koopa_message "Adding '${symlink}'."
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

_koopa_update_shells() {                                                  # {{{1
    # """
    # Update shell configuration.
    # Updated 2020-01-16.
    # """
    _koopa_assert_has_sudo
    local shell_name
    shell_name="${1:?}"
    local shell_exe
    shell_exe="$(_koopa_make_prefix)/bin/${shell_name}"
    local shell_etc_file
    shell_etc_file="/etc/shells"
    if ! grep -q "$shell_exe" "$shell_etc_file"
    then
        _koopa_message "Updating '${shell_etc_file}' to include '${shell_exe}'."
        sudo sh -c "echo ${shell_exe} >> ${shell_etc_file}"
    else
        _koopa_success "'${shell_exe}' already defined in '${shell_etc_file}'."
    fi
    _koopa_note "Run 'chsh -s ${shell_exe} ${USER}' to change default shell."
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
