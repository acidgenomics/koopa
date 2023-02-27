#!/usr/bin/env bash

koopa_zsh_compaudit_set_permissions() {
    # """
    # Fix ZSH permissions, to ensure 'compaudit' checks pass during 'compinit'.
    # @note Updated 2023-02-27.
    #
    # @seealso
    # - echo "$FPATH" (string) or echo "$fpath" (array)
    # - https://github.com/ohmyzsh/ohmyzsh/blob/master/oh-my-zsh.sh
    # """
    local dict prefix prefixes
    koopa_assert_has_no_args "$#"
    koopa_assert_is_owner
    declare -A dict=(
        ['koopa_prefix']="$(koopa_koopa_prefix)"
        ['opt_prefix']="$(koopa_opt_prefix)"
        ['user_id']="$(koopa_user_id)"
    )
    prefixes=(
        "${dict['koopa_prefix']}/lang/shell/zsh"
        "${dict['opt_prefix']}/zsh/share/zsh"
    )
    for prefix in "${prefixes[@]}"
    do
        [[ -d "$prefix" ]] || continue
        if [[ "$(koopa_stat_user "$prefix")" != "${dict['user_id']}" ]]
        then
            koopa_alert "Fixing ownership at '${prefix}'."
            koopa_chown --recursive --sudo "${dict['user_id']}" "$prefix"
        fi
        if [[ "$(koopa_stat_access_octal "$prefix")" != '755' ]]
        then
            koopa_alert "Fixing write access at '${prefix}'."
            koopa_chmod --recursive 'g-w' "$prefix"
        fi
    done
    return 0
}