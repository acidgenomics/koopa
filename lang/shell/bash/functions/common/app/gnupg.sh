#!/usr/bin/env bash

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
