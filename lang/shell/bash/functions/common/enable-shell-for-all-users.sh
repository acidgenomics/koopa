#!/usr/bin/env bash

koopa_enable_shell_for_all_users() {
    # """
    # Enable shell.
    # @note Updated 2022-04-08.
    #
    # @usage
    # > koopa_enable_shell_for_all_users APP...
    #
    # @examples
    # > koopa_enable_shell_for_all_users \
    # >     '/opt/koopa/bin/bash' \
    # >     /opt/koopa/bin/zsh'
    # """
    local app apps dict
    koopa_assert_has_args "$#"
    koopa_is_admin || return 0
    declare -A dict=(
        [etc_file]='/etc/shells'
        [user]="$(koopa_user)"
    )
    apps=("$@")
    # Intentionally not checking to see whether file exists here.
    # > koopa_assert_is_executable "${apps[@]}"
    for app in "${apps[@]}"
    do
        if ! koopa_file_detect_fixed \
            --file="${dict[etc_file]}" \
            --pattern="$app"
        then
            koopa_alert "Updating '${dict[etc_file]}' to include '${app}'."
            koopa_sudo_append_string \
                --file="${dict[etc_file]}" \
                --string="$app"
        else
            koopa_alert_note "'$app' already defined in '${dict[etc_file]}'."
        fi
    done
    if [[ "$#" -eq 1 ]]
    then
        koopa_alert_info "Run 'chsh -s ${apps[0]} ${dict[user]}' to change \
the default shell."
    fi
    return 0
}
