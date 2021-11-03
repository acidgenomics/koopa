#!/usr/bin/env bash

koopa::gpg_download_key_from_keyserver() { # {{{1
    # """
    # Download a GPG key from a keyserver to a local file, without importing.
    # @note Updated 2021-11-03.
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
