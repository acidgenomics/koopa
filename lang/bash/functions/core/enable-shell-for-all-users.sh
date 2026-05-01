#!/usr/bin/env bash

_koopa_enable_shell_for_all_users() {
    # """
    # Enable shell.
    # @note Updated 2022-09-12.
    #
    # @usage
    # > _koopa_enable_shell_for_all_users APP...
    #
    # @examples
    # > _koopa_enable_shell_for_all_users \
    # >     '/opt/koopa/bin/bash' \
    # >     /opt/koopa/bin/zsh'
    # """
    local -A dict
    local -a apps
    local app
    _koopa_assert_has_args "$#"
    _koopa_is_admin || return 0
    dict['etc_file']='/etc/shells'
    dict['user']="$(_koopa_user_name)"
    apps=("$@")
    # Intentionally not checking to see whether file exists here.
    # > _koopa_assert_is_executable "${apps[@]}"
    for app in "${apps[@]}"
    do
        if _koopa_file_detect_fixed \
            --file="${dict['etc_file']}" \
            --pattern="$app"
        then
            continue
        fi
        _koopa_alert "Updating '${dict['etc_file']}' to include '${app}'."
        _koopa_sudo_append_string \
            --file="${dict['etc_file']}" \
            --string="$app"
        _koopa_alert_info "Run 'chsh -s ${app} ${dict['user']}' to change the \
default shell."
    done
    return 0
}
