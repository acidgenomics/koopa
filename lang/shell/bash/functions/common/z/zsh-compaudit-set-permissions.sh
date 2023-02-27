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
        ['app_prefix']="$(koopa_app_prefix)"
        ['koopa_prefix']="$(koopa_koopa_prefix)"
    )
    koopa_chmod --recursive 'g-w' \
        "${dict['koopa_prefix']}/lang/shell/zsh"
    if [[ -d "${dict['app_prefix']}/zsh" ]]
    then
        koopa_chmod --recursive 'g-w' \
            "${dict['app_prefix']}/zsh/"*'/share/zsh'
    fi
    return 0
}
