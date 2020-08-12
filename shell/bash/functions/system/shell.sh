#!/usr/bin/env bash

koopa::enable_shell() { # {{{1
    # """
    # Enable shell.
    # @note Updated 2020-07-07.
    # """
    local cmd_name cmd_path etc_file
    koopa::assert_has_args "$#"
    koopa::has_sudo || return 0
    cmd_name="${1:?}"
    cmd_path="$(koopa::make_prefix)/bin/${cmd_name}"
    etc_file='/etc/shells'
    [[ -f "$etc_file" ]] || return 0
    koopa::info "Updating '${etc_file}' to include '${cmd_path}'."
    if ! grep -q "$cmd_path" "$etc_file"
    then
        sudo sh -c "printf '%s\n' '${cmd_path}' >> '${etc_file}'"
    else
        koopa::success "'${cmd_path}' already defined in '${etc_file}'."
    fi
    koopa::note "Run 'chsh -s ${cmd_path} ${USER}' to change default shell."
    return 0
}
