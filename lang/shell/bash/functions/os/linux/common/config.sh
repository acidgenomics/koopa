#!/usr/bin/env bash

koopa::linux_add_user_to_etc_passwd() { # {{{1
    # """
    # Any any type of user, including domain user to passwd file.
    # @note Updated 2022-02-17.
    #
    # Necessary for running 'chsh' with a Kerberos / Active Directory domain
    # account, on AWS or Azure for example.
    #
    # Note that this function will enable use of RStudio for domain users.
    #
    # @examples
    # > koopa::linux_add_user_to_etc_passwd 'domain.user'
    # """
    local dict
    koopa::assert_has_args_le "$#" 1
    declare -A dict=(
        [passwd_file]='/etc/passwd'
        [user]="${1:-}"
    )
    koopa::assert_is_file "${dict[passwd_file]}"
    [[ -z "${dict[user]}" ]] && dict[user]="$(koopa::user)"
    if ! koopa::file_detect_fixed \
        --file="${dict[passwd_file]}" \
        --pattern="${dict[user]}" \
        --sudo
    then
        koopa::alert "Updating '${dict[passwd_file]}' to \
include '${dict[user]}'."
        dict[user_string]="$(getent passwd "${dict[user]}")"
        koopa::sudo_append_string "${dict[user_string]}" "${dict[passwd_file]}"
    else
        koopa::alert_note "'${dict[user]}' already defined \
in '${dict[passwd_file]}'."
    fi
    return 0
}

koopa::linux_add_user_to_group() { # {{{1
    # """
    # Add user to group.
    # @note Updated 2021-11-16.
    #
    # Alternate approach:
    # > "${app[usermod]}" -a -G group user
    #
    # @examples
    # > koopa::linux_add_user_to_group 'docker'
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

koopa::linux_remove_user_from_group() { # {{{1
    # """
    # Remove user from group.
    # @note Updated 2021-11-16.
    #
    # @examples
    # koopa::linux_remove_user_from_group 'docker'
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

koopa::linux_update_etc_profile_d() { # {{{1
    # """
    # Link shared 'zzz-koopa.sh' configuration file into '/etc/profile.d/'.
    # @note Updated 2021-11-16.
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

koopa::linux_update_ldconfig() { # {{{1
    # """
    # Update dynamic linker (LD) configuration.
    # @note Updated 2022-01-31.
    # """
    local app dict source_file
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
        local target_bn target_file
        target_bn="koopa-$(koopa::basename "$source_file")"
        target_file="${dict[target_prefix]}/${target_bn}"
        koopa::ln --sudo "$source_file" "$target_file"
    done
    "${app[sudo]}" "${app[ldconfig]}" || true
    return 0
}
