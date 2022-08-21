#!/usr/bin/env bash

koopa_opt_version() {
    # """
    # Get the current version of linked app in opt.
    # @note Updated 2022-06-23.
    #
    # @examples
    # > koopa_opt_version 'vim'
    # """
    local dict
    koopa_assert_has_args_eq "$#" 1
    declare -A dict=(
        ['name']="${1:?}"
        ['opt_prefix']="$(koopa_opt_prefix)"
    )
    dict['symlink']="${dict['opt_prefix']}/${dict['name']}"
    koopa_assert_is_symlink "${dict['symlink']}"
    dict['realpath']="$(koopa_realpath "${dict['symlink']}")"
    dict['version']="$(koopa_basename "${dict['realpath']}")"
    koopa_print "${dict['version']}"
    return 0
}
