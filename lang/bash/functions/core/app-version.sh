#!/usr/bin/env bash

_koopa_app_version() {
    # """
    # Get the current version of linked app in opt.
    # @note Updated 2022-10-11.
    #
    # @examples
    # > _koopa_app_version 'vim'
    # """
    local -A dict
    _koopa_assert_has_args_eq "$#" 1
    dict['name']="${1:?}"
    dict['opt_prefix']="$(_koopa_opt_prefix)"
    dict['symlink']="${dict['opt_prefix']}/${dict['name']}"
    _koopa_assert_is_symlink "${dict['symlink']}"
    dict['realpath']="$(_koopa_realpath "${dict['symlink']}")"
    dict['version']="$(_koopa_basename "${dict['realpath']}")"
    _koopa_print "${dict['version']}"
    return 0
}
