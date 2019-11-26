#!/bin/sh
# shellcheck disable=SC2039

_koopa_make_build_string() {                                              # {{{3
    # """
    # OS build string for 'make' configuration.
    # Updated 2019-09-27.
    #
    # Use this for 'configure --build' flag.
    #
    # This function will distinguish between RedHat, Amazon, and other distros
    # instead of just returning "linux". Note that we're substituting "redhat"
    # instead of "rhel" here, when applicable.
    #
    # - AWS:    x86_64-amzn-linux-gnu
    # - Darwin: x86_64-darwin15.6.0
    # - RedHat: x86_64-redhat-linux-gnu
    # """
    local mach
    local os_id
    local string
    mach="$(uname -m)"
    if _koopa_is_darwin
    then
        string="${mach}-${OSTYPE}"
    else
        os_id="$(_koopa_os_id)"
        if echo "$os_id" | grep -q "rhel"
        then
            os_id="redhat"
        fi
        string="${mach}-${os_id}-${OSTYPE}"
    fi
    echo "$string"
}

_koopa_prefix_chgrp() {                                                   # {{{3
    # """
    # Fix the group permissions on the target build prefix.
    # Updated 2019-10-22.
    # """
    local path
    local group
    path="$1"
    group="$(_koopa_group)"
    if _koopa_has_sudo
    then
        sudo chgrp -Rh "$group" "$path"
        sudo chmod -R g+w "$path"
    else
        chgrp -Rh "$group" "$path"
        chmod -R g+w "$path"
    fi
}

_koopa_prefix_mkdir() {                                                   # {{{3
    # """
    # Create directory in target build prefix.
    # Updated 2019-10-22.
    #
    # Sets correct group and write permissions automatically.
    # """
    local path
    path="$1"
    _koopa_assert_is_not_dir "$path"
    if _koopa_has_sudo
    then
        sudo mkdir -p "$path"
        sudo chown "$(whoami)" "$path"
    else
        mkdir -p "$path"
    fi
    _koopa_prefix_chgrp "$path"
}

_koopa_prepare_make_prefix() {
    # """
    # Ensure the make prefix is writable.
    # Updated 2019-11-25.
    #
    # Run this function prior to cellar installs.
    # """
    local prefix
    prefix="$(_koopa_make_prefix)"
    _koopa_set_permissions "$prefix"
    if _koopa_is_shared_install
    then
        sudo chmod g+s "$prefix"
    else
        chmod g+s "$prefix"
    fi
    return 0
}

_koopa_reset_prefix_permissions() {
    # """
    # Reset prefix permissions.
    # Updated 2019-11-26.
    # """
    prefix="${1:-}"
    if [ -z "$prefix" ]
    then
        prefix="$(_koopa_make_prefix)"
    fi
    _koopa_set_permissions "$prefix"
    # Ensure group on top level is sticky.
    if _koopa_is_shared_install
    then
        sudo chmod g+s "$prefix"
    else
        chmod g+s "$prefix"
    fi
    return 0
}

_koopa_set_permissions() {                                                # {{{3
    # """
    # Set permissions on a koopa-related directory.
    # Updated 2019-11-26.
    #
    # Generally used to reset the build prefix directory (e.g. '/usr/local').
    # """
    local path
    path="$1"
    _koopa_message "Setting permissions on '${path}'."
    if _koopa_is_shared_install
    then
        _koopa_assert_has_sudo
        sudo chown -Rh "root" "$path"
    else
        chown -Rh "$(whoami)" "$path"
    fi
    _koopa_prefix_chgrp "$path"
    return 0
}

_koopa_update_ldconfig() {                                                # {{{3
    # """
    # Update dynamic linker (LD) configuration.
    # Updated 2019-10-27.
    # """
    _koopa_is_linux || return 0
    _koopa_has_sudo || return 0
    [ -d /etc/ld.so.conf.d ] || return 0
    _koopa_assert_is_installed ldconfig
    local os_id
    os_id="$(_koopa_os_id)"
    local conf_source
    conf_source="${KOOPA_PREFIX}/os/${os_id}/etc/ld.so.conf.d"
    if [ ! -d "$conf_source" ]
    then
        _koopa_stop "Source files missing: '${conf_source}'."
    fi
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
}

_koopa_update_lmod_config() {                                             # {{{3
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

_koopa_update_profile() {                                                 # {{{3
    # """
    # Link shared 'zzz-koopa.sh' configuration file into '/etc/profile.d/'.
    # Updated 2019-11-05.
    # """
    local symlink
    _koopa_is_linux || return 0
    _koopa_has_sudo || return 0
    symlink="/etc/profile.d/zzz-koopa.sh"
    # > [ -L "$symlink" ] && return 0
    _koopa_message "Adding '${symlink}'."
    sudo rm -fv "/etc/profile.d/koopa.sh"
    sudo ln -fnsv \
        "$(_koopa_prefix)/os/linux/etc/profile.d/zzz-koopa.sh" \
        "$symlink"
    return 0
}

_koopa_update_r_config() {                                                # {{{3
    # """
    # Add shared R configuration symlinks in '${R_HOME}/etc'.
    # Updated 2019-10-22.
    # """
    _koopa_has_sudo || return 0
    _koopa_is_installed R || return 0
    local r_home
    r_home="$(_koopa_r_home)"
    # > local version
    # > version="$( \
    # >     R --version | \
    # >     head -n 1 | \
    # >     cut -d ' ' -f 3 | \
    # >     grep -Eo "^[0-9]+\.[0-9]+"
    # > )"
    _koopa_message "Updating '${r_home}'."
    local os_id
    os_id="$(_koopa_os_id)"
    local r_etc_source
    r_etc_source="${KOOPA_PREFIX}/os/${os_id}/etc/R"
    if [ ! -d "$r_etc_source" ]
    then
        _koopa_stop "Source files missing: '${r_etc_source}'."
    fi
    sudo ln -fnsv "${r_etc_source}/"* "${r_home}/etc/".
    _koopa_message "Creating site library."
    site_library="${r_home}/site-library"
    sudo mkdir -pv "$site_library"
    _koopa_set_permissions "$r_home"
    _koopa_r_javareconf
}

_koopa_update_r_config_macos() {                                          # {{{3
    # """
    # Update R config on macOS.
    # Updated 2019-10-31.
    #
    # Need to include Makevars to build packages from source.
    # """
    mkdir -pv "${HOME}/.R"
    ln -fnsv "/usr/local/koopa/os/darwin/etc/R/Makevars" "${HOME}/.R/."
}

_koopa_update_shells() {                                                  # {{{3
    # """
    # Update shell configuration.
    # Updated 2019-09-28.
    # """
    local shell
    local shell_file
    _koopa_assert_has_sudo
    shell="$(_koopa_make_prefix)/bin/${1}"
    shell_file="/etc/shells"
    if ! grep -q "$shell" "$shell_file"
    then
        _koopa_message "Updating '${shell_file}' to include '${shell}'."
        sudo sh -c "echo ${shell} >> ${shell_file}"
    fi
    _koopa_note "Run 'chsh -s ${shell} ${USER}' to change the default shell."
}

_koopa_update_xdg_config() {                                              # {{{3
    # """
    # Update XDG configuration.
    # Updated 2019-10-27.
    #
    # Path: '~/.config/koopa'.
    # """
    local config_dir
    config_dir="$(_koopa_config_prefix)"
    local home_dir
    home_dir="$(_koopa_prefix)"
    local os_id
    os_id="$(_koopa_os_id)"
    mkdir -pv "$config_dir"
    relink() {
        local source_file
        source_file="$1"
        local dest_file
        dest_file="$2"
        if [ ! -e "$dest_file" ]
        then
            if [ ! -e "$source_file" ]
            then
                _koopa_warning "Source file missing: '${source_file}'."
                return 1
            fi
            _koopa_message "Updating XDG config in '${config_dir}'."
            rm -fv "$dest_file"
            ln -fnsv "$source_file" "$dest_file"
        fi
    }
    relink "${home_dir}" "${config_dir}/home"
    relink "${home_dir}/activate" "${config_dir}/activate"
    if [ -d "${home_dir}/os/${os_id}" ]
    then
        relink "${home_dir}/os/${os_id}/etc/R" "${config_dir}/R"
    fi
}
