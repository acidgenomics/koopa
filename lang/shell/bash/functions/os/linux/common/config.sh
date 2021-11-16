#!/usr/bin/env bash

# FIXME Need to add linux prefix.
koopa::add_user_to_etc_passwd() { # {{{1
    # """
    # Any any type of user, including domain user to passwd file.
    # @note Updated 2021-10-27.
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
    user="${1:-}"
    [[ -z "${user:-}" ]] && user="$(koopa::user)"
    if ! koopa::file_match_fixed --sudo "$passwd_file" "$user"
    then
        koopa::alert "Updating '${passwd_file}' to include '${user}'."
        user_string="$(getent passwd "$user")"
        koopa::sudo_append_string "$user_string" "$passwd_file"
    else
        koopa::alert_note "'${user}' already defined in '${passwd_file}'."
    fi
    return 0
}

# FIXME Need to add linux prefix.
koopa::add_user_to_group() { # {{{1
    # """
    # Add user to group.
    # @note Updated 2021-11-16.
    #
    # Alternate approach:
    # > usermod -a -G group user
    #
    # @examples
    # koopa::add_user_to_group 'docker'
    # """
    local app dict
    koopa::assert_has_args_le "$#" 2
    koopa::assert_is_admin
    declare -A app=(
        [gpasswd]="$(koopa::linux_locate_gpasswd)"
        [sudo]="$(koopa::locate_sudo)"
    )
    declare -A dict=(
        [group]="${1:?}"
        [user]="${2:-}"
    )
    [[ -z "${dict[user]}" ]] && dict[user]="$(koopa::user)"
    koopa::alert "Adding user '${dict[user]}' to group '${dict[group]}'."
    "${app[sudo]}" "${app[gpasswd]}" --add "${dict[user]}" "${dict[group]}"
    return 0
}

# FIXME Need to add linux prefix.
koopa::link_docker() { # {{{1
    # """
    # Link Docker library onto data disk for VM.
    # @note Updated 2021-11-16.
    # """
    local app dict
    koopa::assert_has_no_args "$#"
    koopa::assert_is_admin
    declare -A app=(
        [sudo]="$(koopa::locate_sudo)"
        [systemctl]="$(koopa::linux_locate_systemctl)"
    )
    declare -A dict=(
        # e.g. '/mnt/data01/n' to '/n' for AWS.
        [dd_link_prefix]="$(koopa::data_disk_link_prefix)"
        [distro_prefix]="$(koopa::distro_prefix)"
        [etc_target]='/etc/docker'
        [lib_sys]='/var/lib/docker'
    )
    dict[etc_source]="${dict[distro_prefix]}${dict[etc_target]}"
    dict[lib_n]="${dict[dd_link_prefix]}${dict[lib_sys]}"
    koopa::assert_is_dir "${dict[dd_link_prefix]}"
    koopa::alert 'Updating Docker configuration.'
    koopa::alert_note 'Stopping Docker.'
    "${app[sudo]}" "${app[systemctl]}" stop 'docker'
    koopa::alert_note "Moving Docker lib from '${dict[lib_sys]}' \
to '${dict[lib_n]}'."
    if [[ -d "${dict[etc_source]}" ]]
    then
        koopa::ln \
            --sudo \
            --target-directory="${dict[etc_target]}" \
            "${dict[etc_source]}/"*
    fi
    koopa::rm --sudo "${dict[lib_sys]}"
    koopa::mkdir --sudo "${dict[lib_n]}"
    koopa::ln --sudo "${dict[lib_n]}" "${dict[lib_sys]}"
    koopa::alert_note 'Restarting Docker.'
    "${app[sudo]}" "${app[systemctl]}" enable 'docker'
    "${app[sudo]}" "${app[systemctl]}" start 'docker'
    return 0
}

# FIXME Need to add linux prefix.
koopa::remove_user_from_group() { # {{{1
    # """
    # Remove user from group.
    # @note Updated 2021-11-16.
    #
    # @examples
    # koopa::remove_user_from_group 'docker'
    # """
    local app dict
    koopa::assert_has_args_le "$#" 2
    koopa::assert_is_admin
    declare -A app=(
        [gpasswd]="$(koopa::linux_locate_gpasswd)"
        [sudo]="$(koopa::locate_sudo)"
    )
    declare -A dict=(
        [group]="${1:?}"
        [user]="${2:-}"
    )
    [[ -z "${dict[user]}" ]] && dict[user]="$(koopa::user)"
    "${app[sudo]}" "${app[gpasswd]}" --delete "${dict[user]}" "${dict[group]}"
    return 0
}

# FIXME Need to add linux prefix.
koopa::update_etc_profile_d() { # {{{1
    # """
    # Link shared 'zzz-koopa.sh' configuration file into '/etc/profile.d/'.
    # @note Updated 2021-11-11.
    # """
    local dict
    koopa::assert_has_no_args "$#"
    koopa::is_shared_install || return 0
    koopa::assert_is_admin
    declare -A dict=(
        [koopa_prefix]="$(koopa::koopa_prefix)"
        [file]='/etc/profile.d/zzz-koopa.sh'
    )
    # Early return if file exists and is not a symlink.
    # Previous verisons of koopa prior to 2020-05-09 created a symlink here.
    if [[ -f "${dict[file]}" ]] && [[ ! -L "${dict[file]}" ]]
    then
        return 0
    fi
    koopa::alert "Adding koopa activation to '${dict[file]}'."
    koopa::rm --sudo "${dict[file]}"
    read -r -d '' "dict[string]" << END || true
#!/bin/sh

__koopa_activate_shared_profile() { # {{{1
    # """
    # Activate koopa shell for all users.
    # @note Updated 2021-11-11.
    # @seealso
    # - https://koopa.acidgenomics.com/
    # """
    # shellcheck source=/dev/null
    . "${dict[koopa_prefix]}/activate"
    return 0
}

__koopa_activate_shared_profile
END
    koopa::sudo_write_string "${dict[string]}" "${dict[file]}"
}

# FIXME Need to add linux prefix.
koopa::update_ldconfig() { # {{{1
    # """
    # Update dynamic linker (LD) configuration.
    # @note Updated 2021-10-31.
    # """
    local app dict source_file target_bn target_file
    koopa::assert_has_no_args "$#"
    koopa::assert_is_admin
    declare -A app=(
        [ldconfig]="$(koopa::linux_locate_ldconfig)"
        [sudo]="$(koopa::locate_sudo)"
    )
    declare -A dict=(
        [distro_prefix]="$(koopa::distro_prefix)"
        [target_prefix]='/etc/ld.so.conf.d'
    )
    [[ -d "${dict[target_prefix]}" ]] || return 0
    dict[conf_source]="${dict[distro_prefix]}${dict[target_prefix]}"
    # Intentionally early return for distros that don't need configuration.
    [[ -d "${dict[conf_source]}" ]] || return 0
    # Create symlinks with 'koopa-' prefix.
    # Note that we're using shell globbing here.
    # https://unix.stackexchange.com/questions/218816
    koopa::alert "Updating ldconfig in '${dict[target_prefix]}'."
    for source_file in "${dict[conf_source]}/"*".conf"
    do
        target_bn="koopa-$(koopa::basename "$source_file")"
        target_file="${dict[target_prefix]}/${target_bn}"
        koopa::ln --sudo "$source_file" "$target_file"
    done
    "${app[sudo]}" "${app[ldconfig]}" || true
    return 0
}
