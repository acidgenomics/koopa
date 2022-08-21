#!/usr/bin/env bash

koopa_uninstall_dotfiles() {
    # """
    # Uninstall dotfiles.
    # @note Updated 2022-07-15.
    # """
    local app dict
    koopa_assert_has_no_args "$#"
    declare -A app=(
        [bash]="$(koopa_locate_bash)"
    )
    [[ -x "${app['bash']}" ]] || return 1
    declare -A dict=(
        [name]='dotfiles'
        [prefix]="$(koopa_dotfiles_prefix)"
    )
    dict['script']="${dict['prefix']}/uninstall"
    koopa_assert_is_file "${dict['script']}"
    "${app['bash']}" "${dict['script']}"
    koopa_uninstall_app \
        --name="${dict['name']}" \
        --prefix="${dict['prefix']}" \
        "$@"
    return 0
}
