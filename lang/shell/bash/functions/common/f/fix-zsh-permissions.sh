#!/usr/bin/env bash

koopa_fix_zsh_permissions() {
    # """
    # Fix ZSH permissions, to ensure 'compaudit' checks pass.
    # @note Updated 2022-07-26.
    #
    # @seealso
    # - https://github.com/ohmyzsh/ohmyzsh/blob/master/oh-my-zsh.sh
    # """
    local dict
    koopa_assert_has_no_args "$#"
    declare -A dict=(
        [app_prefix]="$(koopa_app_prefix)"
        [koopa_prefix]="$(koopa_koopa_prefix)"
    )
    if koopa_is_shared_install
    then
        dict['stat_user']="$( \
            koopa_stat_user "${dict['koopa_prefix']}/lang/shell/zsh" \
        )"
        if [[ "${dict['stat_user']}" != 'root' ]]
        then
            koopa_chown --sudo 'root' \
                "${dict['koopa_prefix']}/lang/shell/zsh" \
                "${dict['koopa_prefix']}/lang/shell/zsh/functions"
            koopa_chmod --sudo 'g-w' \
                "${dict['koopa_prefix']}/lang/shell/zsh" \
                "${dict['koopa_prefix']}/lang/shell/zsh/functions"
        fi
    else
        koopa_chmod 'g-w' \
            "${dict['koopa_prefix']}/lang/shell/zsh" \
            "${dict['koopa_prefix']}/lang/shell/zsh/functions"
    fi
    if [[ -d "${dict['app_prefix']}/zsh" ]]
    then
        koopa_chmod 'g-w' \
            "${dict['app_prefix']}/zsh/"*'/share/zsh' \
            "${dict['app_prefix']}/zsh/"*'/share/zsh/'* \
            "${dict['app_prefix']}/zsh/"*'/share/zsh/'*'/functions'
    fi
    return 0
}
