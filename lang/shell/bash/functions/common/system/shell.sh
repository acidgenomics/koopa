#!/usr/bin/env bash

koopa::enable_shell() { # {{{1
    # """
    # Enable shell.
    # @note Updated 2021-05-14.
    # """
    local cmd_name cmd_path etc_file user
    koopa::assert_has_args "$#"
    koopa::is_admin || return 0
    cmd_name="${1:?}"
    cmd_path="$(koopa::make_prefix)/bin/${cmd_name}"
    etc_file='/etc/shells'
    [[ -f "$etc_file" ]] || return 0
    koopa::alert "Updating '${etc_file}' to include '${cmd_path}'."
    if ! grep -q "$cmd_path" "$etc_file"
    then
        # FIXME Switch to our append string approach...
        sudo sh -c "printf '%s\n' '${cmd_path}' >> '${etc_file}'"
    else
        koopa::alert_success "'${cmd_path}' already defined in '${etc_file}'."
    fi
    user="$(koopa::user)"
    koopa::alert_note "Run 'chsh -s ${cmd_path} ${user}' to change the \
default shell."
    return 0
}

koopa::reload_shell() { # {{{1
    # """
    # Reload the current shell.
    # @note Updated 2021-03-18.
    # """
    koopa::assert_has_no_args "$#"
    # shellcheck disable=SC2093
    exec "${SHELL:?}" -il
    return 0
}
