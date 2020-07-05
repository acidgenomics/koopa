#!/usr/bin/env bash

koopa::_git_clone_to_config() { # {{{1
    # """
    # Clone a git repo or symlink from monorepo.
    # @note Updated 2020-07-04.
    # """
    koopa::assert_has_args_eq "$#" 1
    local config_prefix name url
    config_prefix="$(koopa::config_prefix)"
    for url in "$@"
    do
        name="$(basename "$url")"
        name="$(koopa::sub '\.git$' '' "$name")"
        if koopa::has_monorepo
        then
            koopa::add_monorepo_config_link "$name"
        else
            koopa::git_clone "$url" "${config_prefix}/${name}"
        fi
    done
    return 0
}

koopa::add_config_link() { # {{{1
    # """
    # Add a symlink into the koopa configuration directory.
    # @note Updated 2020-07-04.
    # """
    koopa::assert_has_args_le "$#" 2
    local config_prefix dest_file dest_name source_file
    source_file="${1:?}"
    koopa::assert_is_existing "$source_file"
    source_file="$(realpath "$source_file")"
    dest_name="${2:-}"
    [ -z "$dest_name" ] && dest_name="$(basename "$source_file")"
    config_prefix="$(koopa::config_prefix)"
    dest_file="${config_prefix}/${dest_name}"
    koopa::rm "$dest_file"
    koopa::ln "$source_file" "$dest_file"
    return 0
}

koopa::add_make_prefix_link() { # {{{1
    # """
    # Ensure 'koopa' is linked inside make prefix.
    # @note Updated 2020-07-03.
    #
    # This is particularly useful for external scripts that source koopa header.
    # This approach works nicely inside a hardened R environment.
    # """
    koopa::assert_has_args_le "$#" 1
    koopa::is_shared_install || return 0
    local koopa_prefix make_prefix source_link target_link
    koopa_prefix="${1:-"$(koopa::prefix)"}"
    make_prefix="$(koopa::make_prefix)"
    [ -d "$make_prefix" ] || return 0
    target_link="${make_prefix}/bin/koopa"
    [ -L "$target_link" ] && return 0
    koopa::info "Adding 'koopa' link inside '${make_prefix}'."
    source_link="${koopa_prefix}/bin/koopa"
    koopa::system_ln "$source_link" "$target_link"
    return 0
}

koopa::add_monorepo_config_link() { # {{{1
    # """
    # Add koopa configuration link from user's git monorepo.
    # @note Updated 2020-07-04.
    # """
    koopa::assert_has_args "$#"
    koopa::assert_has_monorepo
    local monorepo_prefix subdir
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
    koopa::assert_has_args "$#"
    local source_file target_file
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
    koopa::assert_has_args_le "$#" 1
    koopa::assert_is_linux
    local passwd_file user user_string
    passwd_file="/etc/passwd"
    koopa::assert_is_file "$passwd_file"
    user="${1:-${USER:?}}"
    user_string="$(getent passwd "$user")"
    koopa::info "Updating '${passwd_file}' to include '${user}'."
    if ! sudo grep -q "$user" "$passwd_file"
    then
        sudo sh -c "printf '%s\n' '${user_string}' >> '${passwd_file}'"
    else
        koopa::note "$user already defined in '${passwd_file}'."
    fi
    return 0
}

koopa::add_user_to_group() { # {{{1
    # """
    # Add user to group.
    # @note Updated 2020-07-03.
    #
    # Alternate approach:
    # > usermod -a -G group user
    #
    # @examples
    # koopa::add_user_to_group "docker"
    # """
    koopa::assert_has_args_le "$#" 2
    koopa::assert_is_installed gpasswd
    local group user
    group="${1:?}"
    user="${2:-${USER:?}}"
    koopa::info "Adding user '${user}' to group '${group}'."
    sudo gpasswd --add "$user" "$group"
    return 0
}

