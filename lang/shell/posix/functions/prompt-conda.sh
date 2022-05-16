#!/bin/sh

koopa_prompt_conda() {
    # """
    # Get conda environment name for prompt string.
    # @note Updated 2021-08-17.
    # """
    local env
    env="$(koopa_conda_env_name)"
    [ -n "$env" ] || return 0
    koopa_print " conda:${env}"
    return 0
}
