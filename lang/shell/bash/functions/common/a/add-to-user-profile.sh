#!/usr/bin/env bash

koopa_add_to_user_profile() {
    # """
    # Add koopa configuration to user profile.
    # @note Updated 2021-11-11.
    # """
    local dict
    koopa_assert_has_no_args "$#"
    declare -A dict=(
        [file]="$(koopa_find_user_profile)"
    )
    koopa_alert "Adding koopa activation to '${dict[file]}'."
    read -r -d '' "dict[string]" << END || true
__koopa_activate_user_profile() {
    # """
    # Activate koopa shell for current user.
    # @note Updated 2021-11-11.
    # @seealso
    # - https://koopa.acidgenomics.com/
    # """
    local script xdg_config_home
    [ "\$#" -eq 0 ] || return 1
    xdg_config_home="\${XDG_CONFIG_HOME:-}"
    if [ -z "\$xdg_config_home" ]
    then
        xdg_config_home="\${HOME:?}/.config"
    fi
    script="\${xdg_config_home}/koopa/activate"
    if [ -r "\$script" ]
    then
        # shellcheck source=/dev/null
        . "\$script"
    fi
    return 0
}

__koopa_activate_user_profile
END
    koopa_append_string \
        --file="${dict[file]}" \
        --string="\n${dict[string]}"
    return 0
}
