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
    local dict
    koopa_assert_has_no_args "$#"
    koopa_assert_is_owner
    declare -A dict=(
        ['koopa_prefix']="$(koopa_koopa_prefix)"
        ['opt_prefix']="$(koopa_opt_prefix)"
    )
    fix_prefix() {
        local prefix
        prefix="${1:?}"
        [[ -d "$prefix" ]] || return 0
        if [[ "$(koopa_stat_access_octal "$prefix")" != '755' ]]
        then
            koopa_alert "Fixing permissions at '${prefix}'."
            koopa_chmod --recursive 'g-w' "$prefix"
        fi
        return 0
    }
    fix_prefix "${dict['koopa_prefix']}/lang/shell/zsh"
    fix_prefix "${dict['opt_prefix']}/zsh/share/zsh"
    unset -f fix_prefix
    return 0
}
