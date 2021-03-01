#!/usr/bin/env bash

koopa::macos_enable_sudo_touch_id() { # {{{1
    # """
    # Enable sudo authentication via Touch ID PAM.
    # @note Updated 2021-03-01.
    # @seealso
    # - https://davidwalsh.name/touch-sudo
    # - https://news.ycombinator.com/item?id=26302139
    # """
    local file pam_prefix
    pam_prefix='/etc/pam.d'
    file="${pam_prefix}/sudo"
    if [[ -f "$file" ]]
    then
        koopa::stop "File exists: '${file}'."
    fi
    # Create the PAM directory, if necessary.
    if [[ ! -d "$pam_prefix" ]]
    then
        koopa::mkdir -S "$pam_prefix"
    fi
    string='auth sufficient pam_tid.so'
    koopa::sudo_write_string "$string" "$file"
    return 0
}
