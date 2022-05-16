#!/usr/bin/env bash

koopa_fix_zsh_permissions() {
    # """
    # Fix ZSH permissions, to ensure 'compaudit' checks pass.
    # @note Updated 2022-04-12.
    # """
    local app dict
    koopa_assert_has_no_args "$#"
    declare -A dict=(
        [app_prefix]="$(koopa_app_prefix)"
        [koopa_prefix]="$(koopa_koopa_prefix)"
    )
    koopa_chmod 'g-w' \
        "${dict[koopa_prefix]}/lang/shell/zsh" \
        "${dict[koopa_prefix]}/lang/shell/zsh/functions"
    if [[ -d "${dict[app_prefix]}/zsh" ]]
    then
        koopa_chmod 'g-w' \
            "${dict[app_prefix]}/zsh/"*'/share/zsh' \
            "${dict[app_prefix]}/zsh/"*'/share/zsh/'* \
            "${dict[app_prefix]}/zsh/"*'/share/zsh/'*'/functions'
    fi
    return 0
}
