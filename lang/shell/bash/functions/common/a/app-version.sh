#!/usr/bin/env bash

koopa_app_version() {
    # """
    # Get the current version of linked app in opt.
    # @note Updated 2022-10-11.
    #
    # @examples
    # > koopa_app_version 'vim'
    # """
    local dict
    declare -A dict
    koopa_assert_has_args_eq "$#" 1
    dict['name']="${1:?}"
    dict['opt_prefix']="$(koopa_opt_prefix)"
    dict['symlink']="${dict['opt_prefix']}/${dict['name']}"
    koopa_assert_is_symlink "${dict['symlink']}"
    dict['realpath']="$(koopa_realpath "${dict['symlink']}")"
    dict['version']="$(koopa_basename "${dict['realpath']}")"
    koopa_print "${dict['version']}"
    return 0
}
