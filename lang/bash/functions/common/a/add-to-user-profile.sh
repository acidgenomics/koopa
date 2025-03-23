#!/usr/bin/env bash

koopa_add_to_user_profile() {
    # """
    # Add koopa configuration to user profile.
    # @note Updated 2023-04-03.
    # """
    local -A dict
    koopa_assert_has_no_args "$#"
    dict['file']="$(koopa_find_user_profile)"
    koopa_alert "Adding koopa activation to '${dict['file']}'."
    read -r -d '' "dict[string]" << END || true
__koopa_activate_user_profile() {
    # """
    # Activate koopa shell for current user.
    # @note Updated 2023-04-03.
    # @seealso 
    # - https://koopa.acidgenomics.com/
    # - https://github.com/acidgenomics/koopa/
    # """
    __kvar_xdg_config_home="\${XDG_CONFIG_HOME:-}"
    if [ -z "\$__kvar_xdg_config_home" ]
    then
        __kvar_xdg_config_home="\${HOME:?}/.config"
    fi
    __kvar_script="\${__kvar_xdg_config_home}/koopa/activate"
    if [ -r "\$__kvar_script" ]
    then
        # shellcheck source=/dev/null
        . "\$__kvar_script"
    fi
    unset -v __kvar_script __kvar_xdg_config_home
    return 0
}

__koopa_activate_user_profile
END
    koopa_append_string \
        --file="${dict['file']}" \
        --string="\n${dict['string']}"
    return 0
}
