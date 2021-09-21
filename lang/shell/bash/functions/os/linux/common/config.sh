#!/usr/bin/env bash

koopa::add_user_to_etc_passwd() { # {{{1
    # """
    # Any any type of user, including domain user to passwd file.
    # @note Updated 2021-03-18.
    #
    # Necessary for running 'chsh' with a Kerberos / Active Directory domain
    # account, on AWS or Azure for example.
    #
    # Note that this function will enable use of RStudio for domain users.
    # """
    local passwd_file user user_string
    koopa::assert_has_args_le "$#" 1
    passwd_file='/etc/passwd'
    koopa::assert_is_file "$passwd_file"
    user="${1:-$(koopa::user)}"
    user_string="$(getent passwd "$user")"
    koopa::alert "Updating '${passwd_file}' to include '${user}'."
    if ! sudo grep -q "$user" "$passwd_file"
    then
        sudo sh -c "printf '%s\n' '${user_string}' >> '${passwd_file}'"
    else
        koopa::alert_note "$user already defined in '${passwd_file}'."
    fi
    return 0
}

koopa::add_user_to_group() { # {{{1
    # """
    # Add user to group.
    # @note Updated 2021-03-18.
    #
    # Alternate approach:
    # > usermod -a -G group user
    #
    # @examples
    # koopa::add_user_to_group 'docker'
    # """
    local group user
    koopa::assert_has_args_le "$#" 2
    koopa::assert_is_installed 'gpasswd'
    group="${1:?}"
    user="${2:-$(koopa::user)}"
    koopa::alert "Adding user '${user}' to group '${group}'."
    sudo gpasswd --add "$user" "$group"
    return 0
}

koopa::link_docker() { # {{{1
    # """
    # Link Docker library onto data disk for VM.
    # @note Updated 2020-11-12.
    # """
    local dd_link_prefix distro_prefix etc_source lib_n lib_sys
    koopa::assert_has_no_args "$#"
    koopa::is_installed 'docker' || return 0
    koopa::assert_is_admin
    # e.g. '/mnt/data01/n' to '/n' for AWS.
    dd_link_prefix="$(koopa::data_disk_link_prefix)"
    [[ -d "$dd_link_prefix" ]] || return 0
    koopa::alert 'Updating Docker configuration.'
    koopa::assert_is_installed 'systemctl'
    koopa::alert_note 'Stopping Docker.'
    sudo systemctl stop docker
    lib_sys='/var/lib/docker'
    lib_n="${dd_link_prefix}${lib_sys}"
    distro_prefix="$(koopa::distro_prefix)"
    koopa::alert_note "Moving Docker lib from '${lib_sys}' to '${lib_n}'."
    etc_source="${distro_prefix}/etc/docker"
    if [[ -d "$etc_source" ]]
    then
        koopa::ln \
            --sudo \
            --target='/etc/docker' \
            "${etc_source}/"*
    fi
    sudo rm -frv "$lib_sys"
    sudo mkdir -pv "$lib_n"
    sudo ln -fnsv "$lib_n" "$lib_sys"
    koopa::alert_note 'Restarting Docker.'
    sudo systemctl enable docker
    sudo systemctl start docker
    return 0
}

koopa::remove_user_from_group() { # {{{1
    # """
    # Remove user from group.
    # @note Updated 2021-03-18.
    #
    # @examples
    # koopa::remove_user_from_group 'docker'
    # """
    local group user
    koopa::assert_has_args_le "$#" 2
    koopa::assert_is_installed 'gpasswd' 'sudo'
    koopa::assert_is_admin
    group="${1:?}"
    user="${2:-$(koopa::user)}"
    sudo gpasswd --delete "$user" "$group"
    return 0
}

koopa::update_etc_profile_d() { # {{{1
    # """
    # Link shared 'zzz-koopa.sh' configuration file into '/etc/profile.d/'.
    # @note Updated 2021-05-17.
    # """
    local file koopa_prefix string
    koopa::assert_has_no_args "$#"
    koopa::is_shared_install || return 0
    koopa::assert_is_admin
    file='/etc/profile.d/zzz-koopa.sh'
    # Early return if file exists and is not a symlink.
    # Previous verisons of koopa prior to 2020-05-09 created a symlink here.
    if [[ -f "$file" ]] && [[ ! -L "$file" ]]
    then
        return 0
    fi
    sudo rm -fv "$file"
    koopa_prefix="$(koopa::koopa_prefix)"
    read -r -d '' string << END || true
#!/bin/sh

__koopa_activate_shared_profile() { # {{{1
    # """
    # Activate koopa shell for all users.
    # @note Updated 2021-05-17.
    # @seealso https://koopa.acidgenomics.com/
    # """
    # shellcheck source=/dev/null
    source "${koopa_prefix}/activate"
    return 0
}

__koopa_activate_shared_profile
END
    koopa::sudo_write_string "$string" "$file"
}

koopa::update_ldconfig() { # {{{1
    # """
    # Update dynamic linker (LD) configuration.
    # @note Updated 2021-09-21.
    # """
    local conf_source dest_file distro_prefix source_file
    koopa::assert_has_no_args "$#"
    [[ -d '/etc/ld.so.conf.d' ]] || return 0
    koopa::assert_is_installed '/sbin/ldconfig'
    koopa::assert_is_admin
    distro_prefix="$(koopa::distro_prefix)"
    conf_source="${distro_prefix}/etc/ld.so.conf.d"
    # Intentionally early return for distros that don't need configuration.
    [[ -d "$conf_source" ]] || return 0
    # Create symlinks with 'koopa-' prefix.
    # Note that we're using shell globbing here.
    # https://unix.stackexchange.com/questions/218816
    koopa::alert "Updating ldconfig in '/etc/ld.so.conf.d/'."
    for source_file in "${conf_source}/"*".conf"
    do
        dest_file="/etc/ld.so.conf.d/koopa-$(basename "$source_file")"
        koopa::ln --sudo "$source_file" "$dest_file"
    done
    sudo /sbin/ldconfig || true
    return 0
}
