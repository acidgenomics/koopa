#!/usr/bin/env bash

# FIXME Move this outside of apt config, since it's generally useful.
koopa::gpg_download_key_from_keyserver() { # {{{1
    # """
    # Download a GPG key from a keyserver to a local file, without importing.
    # @note Updated 2021-11-03.
    #
    # @section Useful post from Stack Overflow:
    #
    # You can accomplish this by setting the 'GNUPGHOME' environmental variable
    # to another directory, then receive keys to the alt keyring in it. None of
    # the gpg actions you perform in the context of this alternate gnupg home
    # will affect the keyring or any other data in your normal gnupg home.
    #
    # The 'GNUPGHOME' you set will remain in effect only for this terminal
    # session. When you close the terminal window the gnupg home directory will
    # revert to the default '~/.gnupg'. You can either create a persistent
    # directory to use for this or just create a temporary directory on the fly:
    #
    # > export GNUPGHOME=$(mktemp -d)
    #
    # Now retrieve the key:
    #
    # > gpg --keyserver pool.sks-keyservers.net --recv-keys 648ACFD622F3D138
    #
    # Now you can display the info for the imported key:
    #
    # > gpg -k 648ACFD622F3D138
    #
    # And export the ascii-armored key file to your home directory.
    #
    # > gpg -ao ~/648ACFD622F3D138.asc --export 648ACFD622F3D138
    #
    # Just close the terminal window when you're done using the temporary home
    # directory. If you decide you want the key in your keyring, import it from
    # the file you exported.
    #
    # @seealso
    # - https://superuser.com/a/1643115/589630
    # """
    local app dict
    koopa::assert_has_args "$#"
    declare -A app=(
        [gpg]="$(koopa::locate_gpg)"
    )
    declare -A dict=(
        [tmp_dir]="$(koopa::tmp_dir)"
    )
    while (("$#"))
    do
        case "$1" in
            # Key-value pairs --------------------------------------------------
            '--file='*)
                dict[file]="${1#*=}"
                shift 1
                ;;
            '--file')
                dict[file]="${2:?}"
                shift 2
                ;;
            '--key='*)
                dict[key]="${1#*=}"
                shift 1
                ;;
            '--key')
                dict[key]="${2:?}"
                shift 2
                ;;
            '--keyserver='*)
                dict[keyserver]="${1#*=}"
                shift 1
                ;;
            '--keyserver')
                dict[keyserver]="${2:?}"
                shift 2
                ;;
            # Other ------------------------------------------------------------
            *)
                koopa::invalid_arg "$1"
                ;;
        esac
    done
    [[ -f "${dict[file]}" ]] && return 0
    koopa::alert "Exporting GPG key '${dict[key]}' at '${dict[file]}'."
    # > export GNUPGHOME="${dict[tmp_dir]}"
    "${app[gpg]}" \
        --homedir "${dict[tmp_dir]}" \
        --quiet \
        --keyserver "${dict[keyserver]}" \
        --recv-keys "${dict[key]}"
    "${app[gpg]}" \
        --homedir "${dict[tmp_dir]}" \
        --list-public-keys "${dict[key]}"
    "${app[gpg]}" \
        --homedir "${dict[tmp_dir]}" \
        --armor \
        --export \
        --quiet \
        --output "${dict[file]}" \
        "${dict[key]}"
    koopa::rm "${dict[tmp_dir]}"
    koopa::assert_is_file "${dict[file]}"
    return 0
}


koopa::gpg_prompt() { # {{{1
    # """
    # Force GPG to prompt for password.
    # @note Updated 2020-07-10.
    # Useful for building Docker images, etc. inside tmux.
    # """
    koopa::assert_has_no_args "$#"
    koopa::assert_is_installed 'gpg'
    printf '' | gpg -s
    return 0
}

koopa::gpg_reload() { # {{{1
    koopa::assert_has_no_args "$#"
    koopa::assert_is_installed 'gpg-connect-agent'
    gpg-connect-agent reloadagent /bye
    return 0
}

koopa::gpg_restart() { # {{{1
    koopa::assert_has_no_args "$#"
    koopa::assert_is_installed 'gpgconf'
    gpgconf --kill gpg-agent
    return 0
}
