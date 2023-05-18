#!/usr/bin/env bash

koopa_zsh_compaudit_set_permissions() {
    # """
    # Fix ZSH permissions, to ensure 'compaudit' checks pass during 'compinit'.
    # @note Updated 2023-05-18.
    #
    # @seealso
    # - echo "$FPATH" (string) or echo "$fpath" (array)
    # - https://github.com/ohmyzsh/ohmyzsh/blob/master/oh-my-zsh.sh
    # """
    local -A dict
    local -a prefixes
    local prefix
    koopa_assert_has_no_args "$#"
    koopa_assert_is_owner
    dict['koopa_prefix']="$(koopa_koopa_prefix)"
    dict['opt_prefix']="$(koopa_opt_prefix)"
    dict['user_id']="$(koopa_user_id)"
    prefixes=(
        "${dict['koopa_prefix']}/lang/zsh"
        "${dict['opt_prefix']}/zsh/share/zsh"
    )
    for prefix in "${prefixes[@]}"
    do
        local access
        [[ -d "$prefix" ]] || continue
        if [[ "$(koopa_stat_user_id "$prefix")" != "${dict['user_id']}" ]]
        then
            koopa_alert "Fixing ownership at '${prefix}'."
            koopa_chown --recursive --sudo "${dict['user_id']}" "$prefix"
        fi
        # Ensure '2755' returns as '755' for check.
        access="$(koopa_stat_access_octal "$prefix")"
        access="${access: -3}"
        # Alternative method:
        # > access="${access:(-3)}"
        if [[ "$access" != '755' ]]
        then
            koopa_alert "Fixing write access at '${prefix}'."
            koopa_chmod --recursive 'g-w' "$prefix"
        fi
    done
    return 0
}
