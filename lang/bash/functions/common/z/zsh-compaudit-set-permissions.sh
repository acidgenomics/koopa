#!/usr/bin/env bash

koopa_zsh_compaudit_set_permissions() {
    # """
    # Fix ZSH permissions, to ensure 'compaudit' checks pass during 'compinit'.
    # @note Updated 2024-12-03.
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
        local access stat_user_id
        [[ -d "$prefix" ]] || continue
        stat_user_id="$(koopa_stat_user_id "$prefix")"
        if [[ "$stat_user_id" != "${dict['user_id']}" ]]
        then
            koopa_alert "Changing ownership at '${prefix}' from \
'${stat_user_id}' to '${dict['user_id']}'."
            koopa_chown --recursive --sudo "${dict['user_id']}" "$prefix"
        fi
        # Ensure '2755' returns as '755' for check.
        access="$(koopa_stat_access_octal "$prefix")"
        access="${access: -3}"
        # Alternative method:
        # > access="${access:(-3)}"
        case "$access" in
            '700' | \
            '744' | \
            '755')
                ;;
            *)
                koopa_alert "Fixing write access at '${prefix}'."
                koopa_chmod --recursive 'g-w' "$prefix"
                ;;
        esac
    done
    return 0
}
