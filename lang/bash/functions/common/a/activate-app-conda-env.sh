#!/usr/bin/env bash

koopa_activate_app_conda_env() {
    # """
    # Activate internal conda environment inside a koopa app.
    # @note Updated 2023-11-17.
    #
    # @examples
    # koopa_activate_conda_env 'misopy'
    # """
    local -A dict
    koopa_assert_has_args_eq "$#" 1
    dict['app_name']="${1:?}"
    dict['prefix']="$(koopa_app_prefix "${dict['app_name']}")"
    dict['libexec']="${dict['prefix']}/libexec"
    koopa_assert_is_dir "${dict['libexec']}"
    koopa_conda_activate_env "${dict['libexec']}"
    return 0
}
