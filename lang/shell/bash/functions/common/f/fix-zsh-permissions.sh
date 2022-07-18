#!/usr/bin/env bash

koopa_fix_zsh_permissions() {
    # """
    # Fix ZSH permissions, to ensure 'compaudit' checks pass.
    # @note Updated 2022-07-18.
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
        koopa_assert_is_admin
        koopa_chown --sudo 'root' \
            "${dict[koopa_prefix]}/lang/shell/zsh" \
            "${dict[koopa_prefix]}/lang/shell/zsh/functions"
        koopa_chmod --sudo 'g-w' \
            "${dict[koopa_prefix]}/lang/shell/zsh" \
            "${dict[koopa_prefix]}/lang/shell/zsh/functions"
    else
        koopa_chmod 'g-w' \
            "${dict[koopa_prefix]}/lang/shell/zsh" \
            "${dict[koopa_prefix]}/lang/shell/zsh/functions"
    fi
    if [[ -d "${dict[app_prefix]}/zsh" ]]
    then
        koopa_chmod 'g-w' \
            "${dict[app_prefix]}/zsh/"*'/share/zsh' \
            "${dict[app_prefix]}/zsh/"*'/share/zsh/'* \
            "${dict[app_prefix]}/zsh/"*'/share/zsh/'*'/functions'
    fi
    return 0
}
