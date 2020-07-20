#!/usr/bin/env bash

koopa::generate_ssh_key() { # {{{1
    # """
    # Generate SSH key.
    # @note Updated 2020-07-10.
    # This script is called inside 'configure-vm', so don't use assert here.
    # """
    local comment file key_name
    koopa::exit_if_not_installed ssh-keygen
    comment="${USER}@${HOSTNAME}"
    key_name='id_rsa'
    while (("$#"))
    do
        case "$1" in
            --comment=*)
                comment="${1#*=}"
                shift 1
                ;;
            --comment)
                comment="$2"
                shift 2
                ;;
            --key-name=*)
                key_name="${1#*=}"
                shift 1
                ;;
            --key-name)
                key_name="$2"
                shift 2
                ;;
            *)
                koopa::invalid_arg "$1"
                ;;
        esac
    done
    file="${HOME}/.ssh/${key_name}"
    koopa::exit_if_exists "$file"
    ssh-keygen \
        -C "$comment" \
        -N "" \
        -b 4096 \
        -f "$file" \
        -q \
        -t rsa
    koopa::success "Generated SSH key at \"${file}\"."
    return 0
}

koopa::gpg_prompt() { # {{{1
    # """
    # Force GPG to prompt for password.
    # @note Updated 2020-07-10.
    # Useful for building Docker images, etc. inside tmux.
    # """
    koopa::assert_has_no_args "$#"
    koopa::assert_is_installed gpg
    printf '' | gpg -s
    return 0
}

koopa::gpg_reload() { # {{{1
    koopa::assert_has_no_args "$#"
    koopa::assert_is_installed gpg-connect-agent
    gpg-connect-agent reloadagent /bye
    return 0
}

koopa::gpg_restart() { # {{{1
    koopa::assert_has_no_args "$#"
    koopa::assert_is_installed gpgconf
    gpgconf --kill gpg-agent
    return 0
}

